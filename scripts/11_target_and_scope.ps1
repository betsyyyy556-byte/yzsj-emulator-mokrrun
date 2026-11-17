# ============================================================
#  11_target_and_scope.ps1  —  装目标 App（运动世界校园）+ 配作用域 + 环境隐藏
#  用法：
#     .\11_target_and_scope.ps1 -ApkPath D:\pao\dl\运动世界校园.apk
#     不给 -ApkPath 时只做作用域提示与环境隐藏
# ============================================================
param(
  [string]$ApkPath = '',
  [string]$TargetPkg = 'com.zjwh.android_wh_physicalfitness'
)
. (Join-Path $PSScriptRoot 'config.ps1')
$ErrorActionPreference = 'Continue'

$adb = Get-Adb
if (-not $env:PAO_DEV) { $env:PAO_DEV = '127.0.0.1:' + $ADB_PORT }
$dev = $env:PAO_DEV
$S = @('-s', $dev)
& $adb connect $dev | Out-Null
& $adb @S root | Out-Null
Start-Sleep 3
& $adb @S connect $dev | Out-Null

Write-Step "1/5 安装目标 App"
if ($ApkPath -and (Test-Path $ApkPath)) {
  & $adb @S install -r -g $ApkPath 2>&1 | Select-Object -Last 2
} else {
  Write-Host "  未提供 APK。运动世界校园不在应用宝/小米商店上架，用学校通知里的安装包或官网 APK：" -ForegroundColor Yellow
  Write-Host "    .\11_target_and_scope.ps1 -ApkPath 'D:\pao\dl\ydsjxy.apk'" -ForegroundColor DarkCyan
}

Write-Step "2/5 列出第三方包（确认目标包名）"
& $adb @S shell pm list packages -3
$installed = (& $adb @S shell "pm list packages -3") -join "`n"
$hasTarget = $installed -match [regex]::Escape($TargetPkg)
Write-Host ("  目标包 {0} => {1}" -f $TargetPkg, $(if($hasTarget){'已安装'}else{'未安装'}))

Write-Step "3/5 打开 Vector 管理器（配作用域）"
& $adb @S shell "am start -n org.matrix.vector.manager/.activity.MainActivity" 2>&1 | Select-Object -First 2
Write-Host @"
  在弹出来的 Vector 里点：
    模块 -> 随心跑(com.mokrun.app) -> 启用 -> 作用域只勾 $TargetPkg
    模块 -> LocationSpoofer -> 启用 -> 作用域勾自身 + $TargetPkg（两选一，别同时开）
  勾完执行：
    adb shell am force-stop $TargetPkg
"@ -ForegroundColor Cyan

Write-Step "4/5 环境隐藏（脚本可代劳的部分）"
& $adb @S shell "settings put secure mock_location 0"
& $adb @S shell "cmd appops set $TargetPkg android:mock_location deny"
foreach ($p in @($TargetPkg, $MODULE_PKG, $SPOOFER_PKG)) {
  & $adb @S shell "cmd appops set $p SYSTEM_ALERT_WINDOW allow" 2>$null
  & $adb @S shell "pm grant $p android.permission.ACCESS_FINE_LOCATION" 2>$null
  & $adb @S shell "pm grant $p android.permission.ACCESS_COARSE_LOCATION" 2>$null
  & $adb @S shell "pm grant $p android.permission.POST_NOTIFICATIONS" 2>$null
}
# Shamiko 白名单模式：只有列表里的包能看到 root 挂载（更严）
& $adb @S shell "mkdir -p /data/adb/shamiko; ls -l /data/adb/shamiko"

Write-Step "5/5 HMA 模板（UI 操作，脚本只能提示）"
Write-Host @"
  HideMyApplist -> 模板管理 -> 新建「隐藏列表」-> 勾掉：
    随心跑 / LocationSpoofer / Vector / KernelSU / ZygiskNext / Shamiko
  -> 应用管理 -> 选 $TargetPkg -> 使用「隐藏列表」模板
"@ -ForegroundColor Cyan

Write-Host ""
Write-Host "完成后跑一次 05_verify.ps1，再看 VOD-EFFECT.md 的参数表开跑。" -ForegroundColor Green
