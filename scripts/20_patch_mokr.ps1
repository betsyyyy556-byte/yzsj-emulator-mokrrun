# ============================================================
#  20_patch_mokr.ps1  —  把 MokrRun 里硬编码的 com.bxkj.student
#  改成运动世界 com.zjwh.android_wh_physicalfitness，重打包重签
#  依赖：D:\pao\tools\jdk17（解压后的 JDK）+ apktool.jar + uber-apk-signer.jar
# ============================================================
$ErrorActionPreference = 'Continue'
$ROOT   = 'D:\pao'
$TOOLS  = Join-Path $ROOT 'tools'
$WORK   = Join-Path $ROOT 'out\patch'
$APK_IN = Join-Path $ROOT 'dl\MokrRun-1.0.115.apk'
$OLD    = 'com.bxkj.student'
$NEW    = 'com.zjwh.android_wh_physicalfitness'
$OLD_S  = 'com/bxkj/student'
$NEW_S  = 'com/zjwh/android_wh_physicalfitness'

function Log($m){ Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $m" -ForegroundColor Cyan }

# ---- java ----
$java = Get-ChildItem $TOOLS -Recurse -Filter 'java.exe' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\bin\\java\.exe$' } | Select-Object -First 1
if (-not $java) { throw "没找到 java.exe，先把 JDK 解压到 $TOOLS\jdk17" }
$JAVA = $java.FullName
Log "java: $JAVA"
& $JAVA -version 2>&1 | Select-Object -First 1

$APKTOOL = Join-Path $TOOLS 'apktool.jar'
$SIGNER  = Join-Path $TOOLS 'uber-apk-signer.jar'

# ---- 解码 ----
if (Test-Path $WORK) { Remove-Item $WORK -Recurse -Force }
New-Item -ItemType Directory -Path $WORK -Force | Out-Null
Log 'apktool d'
& $JAVA -jar $APKTOOL d -f -o (Join-Path $WORK 'src') $APK_IN 2>&1 | Select-Object -Last 6

# ---- 改包名 ----
$src = Join-Path $WORK 'src'
$hitFiles = Get-ChildItem $src -Recurse -Include '*.smali','*.xml' -File |
            Select-String -Pattern ([regex]::Escape($OLD_S)) -List | Select-Object -ExpandProperty Path
Log ("命中文件 {0} 个" -f ($hitFiles | Measure-Object).Count)
foreach ($f in $hitFiles) {
  $c = Get-Content $f -Raw -Encoding UTF8
  $c = $c.Replace($OLD_S, $NEW_S).Replace($OLD, $NEW)
  Set-Content -Path $f -Value $c -Encoding UTF8 -NoNewline
  Log "  patch $([System.IO.Path]::GetFileName($f))"
}

# Manifest 里的 activity 引用要跟真实 splash 对齐
$mf = Join-Path $src 'AndroidManifest.xml'
if (Test-Path $mf) {
  $m = Get-Content $mf -Raw -Encoding UTF8
  $m = $m.Replace("$NEW.splash.SplashActivity", "$NEW.mvi.splash.SplashActivity")
  Set-Content -Path $mf -Value $m -Encoding UTF8 -NoNewline
  Log '  manifest splash 对齐 mvi.splash.SplashActivity'
}

# ---- 回编译 ----
Log 'apktool b'
$outApk = Join-Path $WORK 'MokrRun-patched-unsigned.apk'
& $JAVA -jar $APKTOOL b (Join-Path $WORK 'src') -o $outApk 2>&1 | Select-Object -Last 8
if (-not (Test-Path $outApk)) { throw '回编译失败' }
Log ("unsigned = {0:N2} MB" -f ((Get-Item $outApk).Length/1MB))

# ---- 签名 ----
Log 'uber-apk-signer'
& $JAVA -jar $SIGNER -a $outApk --allowResign -overwrite 2>&1 | Select-Object -Last 8
$signed = Get-ChildItem $WORK -Filter '*signed*.apk' -Recurse | Select-Object -First 1
if (-not $signed) { $signed = Get-Item $outApk }
Log "signed = $($signed.FullName)"
Copy-Item $signed.FullName (Join-Path $ROOT 'dl\MokrRun-patched.apk') -Force
Log 'DONE -> D:\pao\dl\MokrRun-patched.apk'
