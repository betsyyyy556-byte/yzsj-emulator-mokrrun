# ============================================================
#  01_connect.ps1  —  找 adb、扫端口、连 MuMu 实例、确认 root
# ============================================================
. (Join-Path $PSScriptRoot 'config.ps1')

$adb = Get-Adb
Write-Step "使用 adb: $adb"
& $adb start-server | Out-Null

Write-Step "扫描 MuMu 实例端口（基准 16384，+32/实例）"
$dev = $null
foreach ($p in $PORT_CANDIDATES) {
  $r = & $adb connect "127.0.0.1:$p" 2>&1
  Write-Host ("  try 127.0.0.1:{0} -> {1}" -f $p, ($r -join ' ')) -ForegroundColor DarkGray
  Start-Sleep -Milliseconds 700
  $list = & $adb devices
  if ($list -match "127\.0\.0\.1:$p\s+device") { $dev = "127.0.0.1:$p"; break }
}

if (-not $dev) {
  Write-Host ""
  Write-Host "没连上任何实例。检查清单：" -ForegroundColor Yellow
  Write-Host "  1) MuMu 实例是否已启动并进桌面"
  Write-Host "  2) 设备设置 → 开发者选项 → ADB 调试 是否打开"
  Write-Host "  3) 模拟器右上角菜单 → 设备诊断 → 看真实 ADB 端口，然后手动："
  Write-Host "     & '$adb' connect 127.0.0.1:<端口>"
  throw "ADB 未连接"
}

Write-Step "已连接 $dev"
Log-To 'connect.log' "device=$dev"

& $adb -s $dev shell getprop ro.build.version.release
& $adb -s $dev shell getprop ro.build.version.sdk
& $adb -s $dev shell getprop ro.product.cpu.abi
& $adb -s $dev shell getprop ro.kernel.qemu

Write-Step "确认 Root"
$id = (& $adb -s $dev shell id) -join ''
if ($id -notmatch 'uid=0') {
  Write-Host "  尝试 adb root" -ForegroundColor Yellow
  & $adb -s $dev root | Out-Null
  Start-Sleep 3
  & $adb -s $dev connect $dev | Out-Null
  $id = (& $adb -s $dev shell id) -join ''
}
if ($id -notmatch 'uid=0') {
  Write-Host "  adb 侧非 root，走 su" -ForegroundColor Yellow
  $id = (& $adb -s $dev shell su -c id) -join ''
}
Write-Host ("  id -> {0}" -f $id) -ForegroundColor Green
if ($id -notmatch 'uid=0') {
  Write-Host "  Root 未生效：模拟器 设备设置 → 开发者选项 → 打开 Root 权限 → 重启实例" -ForegroundColor Red
  throw "需要 root"
}

Write-Step "KernelSU 状态"
& $adb -s $dev shell su -c "ls -l /data/adb/ksu/bin/ksud"
& $adb -s $dev shell su -c "/data/adb/ksu/bin/ksud -V"
& $adb -s $dev shell su -c "ls /data/adb/modules"

# 把设备号写进环境，供后续脚本复用
$env:PAO_DEV = $dev
Write-Host ""
Write-Host "设备号已写入 `$env:PAO_DEV = $dev （同一窗口内后续脚本自动复用）" -ForegroundColor Cyan
