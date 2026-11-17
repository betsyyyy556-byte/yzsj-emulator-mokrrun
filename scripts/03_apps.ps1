# ============================================================
#  03_apps.ps1  —  装 App、查包名、处理 x86_64 vs arm64 的 ABI
# ============================================================
. (Join-Path $PSScriptRoot 'config.ps1')

$adb = Get-Adb
$dev = $env:PAO_DEV
if (-not $dev) { throw "先跑 01_connect.ps1" }
$S = @('-s', $dev)

Write-Step "安装 随心跑 MokrRun（隐藏模块：控制端 + LSPosed 模块）"
& $adb @S install -r -g (Join-Path $DL_DIR 'MokrRun-1.0.115.apk')

Write-Step "安装 LocationSpoofer（pao 仓库产物，全局方案）"
$ls = Join-Path $DL_DIR 'LocationSpoofer-v3.1.7-global-64bit-arm64-v8a.apk'
$out = & $adb @S install -r -g $ls 2>&1
Write-Host ("  {0}" -f ($out -join ' ')) -ForegroundColor DarkGray
if (($out -join ' ') -match 'NO_MATCHING_ABIS|INSTALL_FAILED_NO_MATCHING') {
  Write-Host "  ABI 不匹配 → 走 ABI 强制（见下）" -ForegroundColor Yellow
  & $adb @S install -r -g (Join-Path $DL_DIR 'LocationSpoofer-v3.1.7-global-32bit-armeabi-v7a.apk')
}

Write-Step "安装 Hide My Applist（应用列表隐藏）"
& $adb @S install -r -g (Join-Path $DL_DIR 'HMA-V3.8.3.r520.9605640-release.apk')

Write-Step "已安装第三方包"
& $adb @S shell pm list packages -3

Write-Step "确认目标 App 的包名（运动世界校园 = com.zjwh.android_wh_physicalfitness）"
$found = (& $adb @S shell pm list packages -3) -join "`n"
foreach ($p in @($TARGET_PKG, 'com.zjwh.android_wh_physicalfitness')) {
  if ($found -match [regex]::Escape($p)) {
    Write-Host ("  [OK] {0}" -f $p) -ForegroundColor Green
    & $adb @S shell dumpsys package $p | Select-String -Pattern 'versionName|primaryCpuAbi' | Select-Object -First 4
  } else {
    Write-Host ("  [--] {0} 未安装" -f $p) -ForegroundColor DarkGray
  }
}

Write-Step "校验各包实际运行的 ABI"
foreach ($p in @($SPOOFER_PKG, $MODULE_PKG, $TARGET_PKG)) {
  $abi = (& $adb @S shell "pm dump $p 2>/dev/null | grep primaryCpuAbi") -join ''
  if ($abi) { Write-Host ("  {0} -> {1}" -f $p, $abi.Trim()) }
}

Write-Step "ABI 强制配置（仅当 ARM 包闪退/装不上时用）"
$cfgDir = (& $adb @S shell su -c "ls /data/system/etc/mumu-configs/ 2>/dev/null") -join "`n"
Write-Host ($cfgDir.Trim() | Out-String)
& $adb @S shell su -c "for f in /data/system/etc/mumu-configs/abi-select-*.config; do echo \"== \$f\"; tail -n 5 \$f; done"

Write-Host ""
Write-Host @" 
如需强制 ABI，在对应 abi-select-*.config 末尾追加一行（包名 + 架构 + 注释），然后重启实例：

    com.location.spoofer arm64-v8a # LocationSpoofer
    com.mokr.run arm64-v8a # MokrRun

命令：
    `$adb shell su -c "cp /data/system/etc/mumu-configs/abi-select-android15.config /data/local/tmp/a.cfg"
    `$adb pull /data/local/tmp/a.cfg D:\pao\out\a.cfg
    # 编辑 D:\pao\out\a.cfg 追加上述行
    `$adb push D:\pao\out\a.cfg /data/local/tmp/a.cfg
    `$adb shell su -c "cp /data/local/tmp/a.cfg /data/system/etc/mumu-configs/abi-select-android15.config"
    `$adb reboot
"@ -ForegroundColor DarkCyan
