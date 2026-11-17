# ============================================================
#  05_verify.ps1  —  全链路验收 + 截图导出
# ============================================================
. (Join-Path $PSScriptRoot 'config.ps1')
$ErrorActionPreference = 'Continue'

$adb = Get-Adb
$dev = $env:PAO_DEV
if (-not $dev) { throw "先跑 01_connect.ps1" }
$S = @('-s', $dev)

$script:results = @()

function Check {
  param([string]$Name, [scriptblock]$Block, [string]$Expect)
  $val = ''
  $state = 'FAIL'
  try {
    $val = ((& $Block) -join ' ') -replace '\s+', ' '
    $val = $val.Trim()
    $ok = $true
    if ($Expect) { $ok = ($val -match $Expect) }
    if ($val -and $ok) { $state = 'PASS' }
  } catch {
    $val = $_.Exception.Message
  }
  $script:results += [pscustomobject]@{ Item = $Name; Value = $val; State = $state }
}

Write-Step "系统层"
Check 'Android 版本' { & $adb @S shell getprop ro.build.version.release } '^15$'
Check 'API level'    { & $adb @S shell getprop ro.build.version.sdk }     '^35$'
Check 'CPU ABI'      { & $adb @S shell getprop ro.product.cpu.abi }       '\w+'
Check '内核 QEMU 标记' { & $adb @S shell getprop ro.kernel.qemu }         '.+'

Write-Step "Root / 框架层"
Check 'root uid'      { & $adb @S shell su -c id }                          'uid=0'
Check 'ksud'          { & $adb @S shell "/data/adb/ksu/bin/ksud -V" } '.+'
Check 'zygisk 模块'   { & $adb @S shell "ls /data/adb/modules | grep -i zygisk" }  'zygisk'
Check 'vector 模块'   { & $adb @S shell "ls /data/adb/modules | grep -iE 'vector|lsposed'" } '(vector|lsposed)'
Check 'shamiko 模块'  { & $adb @S shell "ls /data/adb/modules | grep -i shamiko" }  'shamiko'

Write-Step "应用层"
Check '目标包已装'   { & $adb @S shell pm list packages -3 | Select-String $TARGET_PKG }  $TARGET_PKG
Check '随心跑已装'   { & $adb @S shell pm list packages -3 | Select-String 'mokr' }        'mokr'
Check 'spoofer 已装' { & $adb @S shell pm list packages -3 | Select-String 'location' }    'location'
Check 'HMA 已装'     { & $adb @S shell pm list packages -3 | Select-String 'applist|hma' } '.*'

Write-Step "hook 运行态（先打开目标 App 再跑本脚本）"
Check 'vector 日志'    { & $adb @S shell "logcat -d | grep -iE 'vector|lsposed' | tail -n 5" } '.+'
Check '模块注入痕迹'   { & $adb @S shell "logcat -d | grep -iE 'mokr|spoofer' | tail -n 5" } '.*'

Write-Step "定位子系统（前 25 行）"
& $adb @S shell dumpsys location | Select-Object -First 25

Write-Step "导出截图"
$shot = Join-Path $OUT_DIR ('verify-{0}.png' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
& $adb @S shell screencap -p /sdcard/v.png
& $adb @S pull /sdcard/v.png $shot 2>$null | Out-Null
Write-Host ("  截图: {0}" -f $shot) -ForegroundColor Green

Write-Host ""
$script:results | Format-Table -AutoSize
$failCount = @($script:results | Where-Object { $_.State -eq 'FAIL' }).Count
Write-Host ("PASS {0} / FAIL {1}" -f ($script:results.Count - $failCount), $failCount)

Write-Host ""
Write-Host "人工验收（视频效果的判定标准）：" -ForegroundColor Cyan
Write-Host @"
  1. 目标 App 启动无「环境异常 / Root 风险 / 模拟器不支持」弹窗
  2. 悬浮窗「开始」后，目标 App 定位落到你画的起点
  3. 不出现「GPS 叉号 / 信号弱 / 轨迹异常」提示
  4. 成绩页：里程与路线长度一致（误差 < 2%）
  5. 配速 5~6 min/km，用时落 5~16 分钟窗口
  6. 步数与里程匹配（步频 160~180）
  7. 中途弹人脸识别时位置冻结，识别完自动续跑（位移不超过 150 米）
"@ -ForegroundColor Cyan
