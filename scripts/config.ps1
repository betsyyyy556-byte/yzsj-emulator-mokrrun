# ============================================================
#  config.ps1  —  全局变量（其余脚本 dot-source 本文件）
#  所有路径固定 D 盘
# ============================================================

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

# ---- 根目录 ----
$PAO_ROOT  = 'D:\pao'
$DL_DIR    = Join-Path $PAO_ROOT 'dl'
$LOG_DIR   = Join-Path $PAO_ROOT 'log'
$OUT_DIR   = Join-Path $PAO_ROOT 'out'

# ---- MuMu（6.x 组件化安装后的实测路径）----
$MUMU_DIR  = 'D:\MuMu\MuMuPlayer-6.0'
$MUMU_ADB  = Join-Path $MUMU_DIR 'nx_device\15.0\shell\adb.exe'
$MUMU_MGR  = Join-Path $MUMU_DIR 'nx_main\MuMuManager.exe'
$ADB_PORT  = 16384
if (-not $env:PAO_DEV) { $env:PAO_DEV = '127.0.0.1:' + $ADB_PORT }

# ---- 实例 / 端口：基准 16384，第 n 个实例 = 16384 + 32n ----
$INSTANCE_INDEX = 0
$PORT_BASE      = 16384
$PORT_STEP      = 32
$PORT_CANDIDATES = @(16384, 16416, 16448, 16480, 16385, 16417)

# ---- 目标应用：运动世界校园 ----
$TARGET_PKG   = 'com.zjwh.android_wh_physicalfitness'
$TARGET_ALIAS = '运动世界校园'
$MODULE_PKG   = 'com.mokr.run'        # 随心跑 MokrRun 的包名（以 pm list 实际值为准）
$SPOOFER_PKG  = 'com.location.spoofer' # LocationSpoofer 包名（以 pm list 实际值为准）

# ---- 运动世界校园 有效区间参考（以本校规定核对后微调）----
# 单次有效里程 >= 2.0 km；配速有效区间 2'00"~10'00"/km => 速度 1.67~8.33 m/s
# 推荐 2.4 m/s（8.6 km/h，配速 6'57"/km），2.2 km 约 15 分钟
$REC_SPEED_MPS = 2.4
$REC_DIST_KM   = 2.2

# ---- 产物清单 ----
$ARTIFACTS = @(
  @{ Name='Zygisk-Next-1.5.3-880-22a1bf5-release.zip'
     Url='https://github.com/Dr-TSNG/ZygiskNext/releases/download/v1.5.3/Zygisk-Next-1.5.3-880-22a1bf5-release.zip'
     Sha='186a0a26c9fcb895af1954b42de831433c23d72d1bd0758b986069154359db67' }

  @{ Name='Vector-v2.2-3080-Release.zip'
     Url='https://github.com/JingMatrix/Vector/releases/download/v2.2/Vector-v2.2-3080-Release.zip'
     Sha='9ee8323575d615f7b3f1076ff60b2a63a49390ef11881b52632311a37f6f79cc' }

  @{ Name='Shamiko-v1.2.5-414-release.zip'
     Url='https://github.com/LSPosed/LSPosed.github.io/releases/download/shamiko-414/Shamiko-v1.2.5-414-release.zip'
     Sha='308d31b2f52a80e49eb58f46bc4c764a6588a79e4b8d101b44860832023f88b4' }

  @{ Name='HMA-V3.8.3.r520.9605640-release.apk'
     Url='https://github.com/Dr-TSNG/Hide-My-Applist/releases/download/v3.8.3/HMA-V3.8.3.r520.9605640-release.apk'
     Sha='3f86c0c35acf9558c4e17905ec64ab8939b595ec25df7fec07d29deec59300a3' }

  @{ Name='LocationSpoofer-v3.1.7-global-64bit-arm64-v8a.apk'
     Url='https://github.com/HuangZhuoRui/LocationSpoofer/releases/download/v3.1.7/LocationSpoofer-v3.1.7-global-64bit-arm64-v8a.apk'
     Sha='5317538da2513e6da7f8b94a9ec5bb79232a5c372f2c711c79a0eebf9affd0de' }

  @{ Name='LocationSpoofer-v3.1.7-global-32bit-armeabi-v7a.apk'
     Url='https://github.com/HuangZhuoRui/LocationSpoofer/releases/download/v3.1.7/LocationSpoofer-v3.1.7-global-32bit-armeabi-v7a.apk'
     Sha='0d5fa466843b49f54ff30d8bee4441e48bd3fdc43f44312567218b7711c7d288' }

  @{ Name='MokrRun-1.0.115.apk'
     Url='https://github.com/QaQ-ciallo/MokrRun/releases/download/v1.0.115/MokrRun-1.0.115.apk'
     Sha='9889ca336738a640e3bd92f56296625093b262731e0fbe088a8fdb50fcdf0859' }

  @{ Name='LSPosed-v1.9.2-7024-zygisk-release.zip'
     Url='https://github.com/LSPosed/LSPosed/releases/download/v1.9.2/LSPosed-v1.9.2-7024-zygisk-release.zip'
     Sha=''
     Optional=$true }
)

# ---- 目录自愈 ----
foreach ($p in @($PAO_ROOT, $DL_DIR, $LOG_DIR, $OUT_DIR)) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

function Get-Adb {
  if (Test-Path $MUMU_ADB) { return $MUMU_ADB }
  $pt = Join-Path $PAO_ROOT 'platform-tools\adb.exe'
  if (Test-Path $pt) { return $pt }
  $cmd = Get-Command adb.exe -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  throw "找不到 adb.exe：请确认 $MUMU_ADB 存在，或把 platform-tools 放到 $PAO_ROOT\platform-tools"
}

function Write-Step($msg) {
  Write-Host ""
  Write-Host "==> $msg" -ForegroundColor Cyan
}

function Log-To($file, $text) {
  $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $text
  Add-Content -Path (Join-Path $LOG_DIR $file) -Value $line -Encoding utf8
}
