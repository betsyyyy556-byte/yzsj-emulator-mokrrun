# ============================================================
#  10_install_mumu.ps1  —  安装 MuMu 6.0 到 D 盘 + 建安卓15实例 + 开 KernelSU Root + 接 ADB
#  需要管理员权限（安装驱动与写入 D:\MuMu）
#  用法：
#     powershell -ExecutionPolicy Bypass -File D:\pao\scripts\10_install_mumu.ps1
# ============================================================
. (Join-Path $PSScriptRoot 'config.ps1')

$logPath = Join-Path $LOG_DIR ('install-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
try { Start-Transcript -Path $logPath -Force | Out-Null } catch { }

$SETUP      = 'D:\pao\dl\MuMu-setup-mumu15-V15.8.4.5735-1010155529.exe'
$INSTALL    = $MUMU_DIR
$VM_INDEX   = 1                      # 0 是本体，新建实例从 1 开始
$VM_NAME    = 'pao-a15'

# ---- 0. 管理员检查 ----
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Write-Host "当前不是管理员，尝试以管理员重新启动本脚本（会弹 UAC）..." -ForegroundColor Yellow
  Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @(
    '-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`""
  )
  return
}

Write-Step "1/6 检查安装包"
if (-not (Test-Path $SETUP)) { throw "缺安装包：$SETUP（先跑 00_download.ps1）" }
$len = (Get-Item $SETUP).Length
Write-Host ("  {0}  {1:N1} MB" -f (Split-Path $SETUP -Leaf), ($len/1MB))

Write-Step "2/6 静默安装到 $INSTALL"
if (Test-Path (Join-Path $INSTALL 'shell\adb.exe')) {
  Write-Host "  已安装，跳过" -ForegroundColor DarkGray
} else {
  # MuMu 安装器为 NSIS 风格：/S 静默，/D= 指定目录（必须是最后一个参数且不带引号）
  $p = Start-Process -FilePath $SETUP -ArgumentList '/S', "/D=$INSTALL" -PassThru
  $deadline = (Get-Date).AddMinutes(15)
  while ((Get-Date) -lt $deadline) {
    if (Test-Path (Join-Path $INSTALL 'shell\adb.exe')) { break }
    if ($p.HasExited -and -not (Test-Path (Join-Path $INSTALL 'shell\adb.exe'))) { break }
    Start-Sleep 5
  }
  if (-not (Test-Path (Join-Path $INSTALL 'shell\adb.exe'))) {
    Write-Host "  静默安装未成功，改为交互安装：请在弹出的向导里把路径改成 $INSTALL" -ForegroundColor Yellow
    Start-Process -FilePath $SETUP -Wait
  }
}

Write-Step "3/6 定位 MuMuManager / adb"
$cands = @(
  (Join-Path $INSTALL 'shell\MuMuManager.exe'),
  (Join-Path $INSTALL 'nx_main\MuMuManager.exe'),
  (Join-Path $INSTALL 'MuMuManager.exe')
)
$mgr = $cands | Where-Object { Test-Path $_ } | Select-Object -First 1
$adb = @((Join-Path $INSTALL 'shell\adb.exe'), (Join-Path $INSTALL 'nx_main\adb.exe')) |
       Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $mgr) { throw "找不到 MuMuManager.exe，检查安装路径 $INSTALL" }
Write-Host "  MuMuManager: $mgr"
Write-Host "  adb:         $adb"

Write-Step "4/6 创建安卓15 实例（索引 $VM_INDEX）并配置"
& $mgr create -v $VM_INDEX
Start-Sleep 3
& $mgr rename -v $VM_INDEX -n $VM_NAME
& $mgr setting -v $VM_INDEX -k performance_cpu.custom -val 4
& $mgr setting -v $VM_INDEX -k performance_mem.custom -val 6
& $mgr setting -v $VM_INDEX -k resolution_mode -val 'phone.1'
& $mgr setting -v $VM_INDEX -k resolution_width.custom -val 1080
& $mgr setting -v $VM_INDEX -k resolution_height.custom -val 1920
& $mgr setting -v $VM_INDEX -k resolution_dpi.custom -val 420
& $mgr setting -v $VM_INDEX -k max_frame_rate -val 60
& $mgr setting -v $VM_INDEX -k renderer_mode -val vk
& $mgr setting -v $VM_INDEX -k root_permission -val true
& $mgr setting -v $VM_INDEX -k phone_brand -val 'Xiaomi'
& $mgr setting -v $VM_INDEX -k phone_model -val '23127PN0CC'
& $mgr setting -v $VM_INDEX -k phone_miit -val '23127PN0CC'
& $mgr setting -v $VM_INDEX -k prevent_sleep -val true

Write-Step "5/6 启动实例并等待 Android 起来"
& $mgr control -v $VM_INDEX launch
$info = $null
$deadline = (Get-Date).AddMinutes(8)
while ((Get-Date) -lt $deadline) {
  $raw = (& $mgr info -v $VM_INDEX) -join ''
  try { $info = $raw | ConvertFrom-Json } catch { $info = $null }
  if ($info -and $info.is_android_started) { break }
  Start-Sleep 5
}
if (-not $info -or -not $info.is_android_started) {
  Write-Host ($raw) -ForegroundColor DarkGray
  throw "实例未启动（可能缺 VT/WHPX 或显卡驱动）。手动开一次实例看报错，再重跑本脚本"
}
Write-Host ("  adb_port = {0}  vt_enabled = {1}  hyperv = {2}" -f $info.adb_port, $info.vt_enabled, $info.hyperv_enabled) -ForegroundColor Green

Write-Step "6/6 连接 ADB 并确认版本与 Root"
$env:PAO_DEV = "127.0.0.1:$($info.adb_port)"
Write-Host "  `$env:PAO_DEV = $env:PAO_DEV"
& $adb start-server | Out-Null
& $adb connect $env:PAO_DEV | Out-Null
Start-Sleep 2
& $adb -s $env:PAO_DEV shell getprop ro.build.version.release
& $adb -s $env:PAO_DEV shell getprop ro.build.version.sdk
& $adb -s $env:PAO_DEV shell id
& $adb -s $env:PAO_DEV shell su -c id

Write-Host ""
Write-Host "Root 刚打开需要重启实例一次才会挂载 KernelSU：" -ForegroundColor Cyan
Write-Host "  & '$mgr' control -v $VM_INDEX restart"
Write-Host "重启后跑：.\\01_connect.ps1"
