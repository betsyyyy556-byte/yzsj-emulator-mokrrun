# ============================================================
#  04_hide.ps1  —  环境隐藏（脚本能做的全做掉，剩下的给 UI 清单）
# ============================================================
. (Join-Path $PSScriptRoot 'config.ps1')

$adb = Get-Adb
$dev = $env:PAO_DEV
if (-not $dev) { throw "先跑 01_connect.ps1" }
$S = @('-s', $dev)
$PKG = $TARGET_PKG

Write-Step "1) 清 mock location 痕迹"
& $adb @S shell su -c "settings put secure mock_location 0"
& $adb @S shell su -c "cmd appops set $PKG android:mock_location deny"
& $adb @S shell su -c "settings get secure mock_location"

Write-Step "2) 目标包绝不授 root（KernelSU 超级用户列表只留 adb/ksud）"
& $adb @S shell su -c "ls /data/adb/ksu/"
& $adb @S shell su -c "cat /data/adb/ksu/.ksurc"

Write-Step "3) Shamiko 模式确认"
& $adb @S shell su -c "mkdir -p /data/adb/shamiko"
& $adb @S shell su -c "ls -l /data/adb/shamiko/"
Write-Host @"
  黑名单模式（默认，无 whitelist 文件）：DenyList 里的包装不到 root 挂载
  白名单模式（/data/adb/shamiko/whitelist 存在）：只有列表里的包能看到 root
  建议：黑名单 + 把目标包加进 DenyList；ZygiskNext 的 Enforce DenyList 与 Shamiko 只开一个
"@ -ForegroundColor DarkCyan

Write-Step "4) 隐藏开发者选项 / ADB 开关（全部调试完成后再执行最后两行）"
& $adb @S shell su -c "settings get global development_settings_enabled"
& $adb @S shell su -c "settings get global adb_enabled"

Write-Step "5) 列出现有模拟器/root 痕迹（用于对照伪装效果）"
& $adb @S shell su -c "getprop | grep -iE 'qemu|goldfish|ranchu|genymotion|mumu|nemu'"
& $adb @S shell su -c "ls /system/lib64/libc_malloc_debug_qemu.so /system/bin/qemud /dev/qemu_pipe"

Write-Step "6) 屏幕状态（悬浮窗定位用）"
& $adb @S shell wm size
& $adb @S shell wm density

Write-Step "7) 给模块放行必要权限（随心跑 / LocationSpoofer 需要悬浮窗+定位+通知）"
foreach ($p in @($MODULE_PKG, $SPOOFER_PKG)) {
  & $adb @S shell su -c "cmd appops set $p SYSTEM_ALERT_WINDOW allow"
  & $adb @S shell su -c "pm grant $p android.permission.ACCESS_FINE_LOCATION"
  & $adb @S shell su -c "pm grant $p android.permission.ACCESS_COARSE_LOCATION"
  & $adb @S shell su -c "pm grant $p android.permission.POST_NOTIFICATIONS"
  & $adb @S shell su -c "cmd appops set $p android:mock_location allow"
}

Write-Host ""
Write-Host "=== 以下 3 项必须在模拟器 UI 里点（脚本无法代劳）===" -ForegroundColor Yellow
Write-Host @"
  A. Vector -> 模块 -> 启用「随心跑」-> 作用域只勾 $PKG ($TARGET_ALIAS)
     再启用「LocationSpoofer」-> 作用域勾自身 + $PKG
     改完必须重启目标进程，模块才会重新注入：
        & '$adb' -s $dev shell am force-stop $PKG

  B. ZygiskNext -> 打开 Enforce DenyList -> 把 $PKG 加进 DenyList
     （与 Shamiko 二选一，别同时生效）

  C. HideMyApplist -> 新建模板「隐藏列表」-> 勾掉
     随心跑 / LocationSpoofer / Vector / KernelSU / ZygiskNext / Shamiko
     -> 应用到 $PKG

  最后一步（正式跑之前才关，否则连不上设备）：
     & '$adb' -s $dev shell su -c "settings put global adb_enabled 0"
     & '$adb' -s $dev shell su -c "settings put global development_settings_enabled 0"
"@ -ForegroundColor Cyan
