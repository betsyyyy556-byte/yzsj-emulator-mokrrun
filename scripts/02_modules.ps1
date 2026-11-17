# ============================================================
#  02_modules.ps1  —  KernelSU 模块安装（ZygiskNext → Vector → Shamiko）
#  顺序不可颠倒：没 Zygisk 装 LSPosed 类框架必失败
# ============================================================
. (Join-Path $PSScriptRoot 'config.ps1')

$adb = Get-Adb
$dev = $env:PAO_DEV
if (-not $dev) { throw "先跑 01_connect.ps1（或手动 `$env:PAO_DEV='127.0.0.1:16384'）" }
$S = @('-s', $dev)

function Wait-Boot {
  param([int]$TimeoutSec = 180)
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  Start-Sleep 5
  & $adb @S connect $dev | Out-Null
  while ((Get-Date) -lt $deadline) {
    $b = (& $adb @S shell getprop sys.boot_completed 2>$null) -join ''
    if ($b.Trim() -eq '1') { Write-Host "  boot_completed=1" -ForegroundColor DarkGray; return }
    Start-Sleep 3
  }
  throw "等待开机超时"
}

function Install-Module {
  param([string]$LocalPath, [string]$RemoteName)
  $r = "/data/local/tmp/$RemoteName"
  Write-Host ("  push {0}" -f (Split-Path $LocalPath -Leaf))
  & $adb @S push $LocalPath $r | Out-Null
  Write-Host "  ksud module install"
  $out = & $adb @S shell su -c "/data/adb/ksu/bin/ksud module install $r" 2>&1
  Write-Host ("  {0}" -f ($out -join ' ')) -ForegroundColor DarkGray
  Log-To 'modules.log' "install $RemoteName :: $($out -join ' ')"
  if (($out -join ' ') -match 'fail|error|不是|无法') { throw "模块安装报错: $RemoteName" }
}

# ---------- 1) ZygiskNext ----------
Write-Step "安装 ZygiskNext（Zygisk 运行时）"
Install-Module (Join-Path $DL_DIR 'Zygisk-Next-1.5.3-880-22a1bf5-release.zip') 'zn.zip'
Write-Step "重启以加载 ZygiskNext"
& $adb @S reboot
Wait-Boot
& $adb @S shell su -c "ls /data/adb/modules"
$zy = (& $adb @S shell su -c "ls /data/adb/modules | grep -i zygisk") -join ''
Write-Host ("  zygisk 模块: {0}" -f $zy) -ForegroundColor Green
if (-not $zy) { throw "ZygiskNext 未出现在 /data/adb/modules，检查 Root 是否真的生效" }

Read-Host "  请打开 ZygiskNext App 确认状态为 Working/Enabled，然后回车继续"

# ---------- 2) Vector (LSPosed 后继) ----------
Write-Step "安装 Vector v2.2（Xposed/LSPosed 框架）"
Install-Module (Join-Path $DL_DIR 'Vector-v2.2-3080-Release.zip') 'vec.zip'
Write-Step "重启以加载 Vector"
& $adb @S reboot
Wait-Boot
& $adb @S shell su -c "ls /data/adb/modules"
& $adb @S shell su -c "logcat -d | grep -iE 'vector|lsposed' | tail -n 20"

Write-Step "确保 Vector 管理器可用（模块内 manager.apk）"
$mgr = (& $adb @S shell su -c "ls /data/adb/modules/*/manager.apk 2>/dev/null") -join "`n"
if ($mgr) {
  $first = ($mgr -split "`n" | Where-Object { $_.Trim() } | Select-Object -First 1).Trim()
  Write-Host ("  找到 {0}" -f $first)
  & $adb @S shell su -c "cp $first /data/local/tmp/vec-manager.apk"
  & $adb @S pull /data/local/tmp/vec-manager.apk (Join-Path $DL_DIR 'vector-manager.apk') | Out-Null
  & $adb @S install -r -g (Join-Path $DL_DIR 'vector-manager.apk')
} else {
  Write-Host "  模块目录没带 manager.apk，桌面找 Vector 图标即可" -ForegroundColor Yellow
}

# ---------- 3) Shamiko ----------
Write-Step "安装 Shamiko（Zygisk 级 root/模块隐藏）"
Install-Module (Join-Path $DL_DIR 'Shamiko-v1.2.5-414-release.zip') 'shamiko.zip'
Write-Step "重启以加载 Shamiko"
& $adb @S reboot
Wait-Boot

Write-Step "模块总览"
& $adb @S shell su -c "ls /data/adb/modules"
& $adb @S shell su -c "ls -d /data/adb/shamiko 2>/dev/null; cat /data/adb/shamiko/whitelist 2>/dev/null"

Write-Host ""
Write-Host "下一步：03_apps.ps1（装 LocationSpoofer / 随心跑 / HMA）" -ForegroundColor Cyan
