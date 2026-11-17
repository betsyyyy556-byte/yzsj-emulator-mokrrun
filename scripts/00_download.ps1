# ============================================================
#  00_download.ps1  —  下载全部产物到 D:\pao\dl 并校验 SHA256
# ============================================================
. (Join-Path $PSScriptRoot 'config.ps1')

Write-Step "下载产物 → $DL_DIR"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Save-File($url, $out) {
  try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 600
  } catch {
    Write-Host "  Invoke-WebRequest 失败，改用 curl.exe" -ForegroundColor Yellow
    & curl.exe -L --fail --retry 3 --retry-delay 3 -o $out $url
    if ($LASTEXITCODE -ne 0) { throw "下载失败: $url" }
  }
}

$fail = @()
foreach ($a in $ARTIFACTS) {
  $out = Join-Path $DL_DIR $a.Name
  $ok  = $false

  if (Test-Path $out) {
    $h = (Get-FileHash $out -Algorithm SHA256).Hash.ToLower()
    if (-not $a.Sha -or $h -eq $a.Sha.ToLower()) {
      Write-Host ("  [SKIP] {0} 已存在且校验通过" -f $a.Name) -ForegroundColor DarkGray
      $ok = $true
    } else {
      Write-Host ("  [REDO] {0} 校验不符，重新下载" -f $a.Name) -ForegroundColor Yellow
    }
  }

  if (-not $ok) {
    Write-Host ("  [GET ] {0}" -f $a.Name) -ForegroundColor Green
    try {
      Save-File $a.Url $out
    } catch {
      if ($a.Optional) {
        Write-Host ("  [SKIP] {0} 是备用件，下载失败不影响主线" -f $a.Name) -ForegroundColor Yellow
        Log-To 'download.log' "SKIP-OPTIONAL $($a.Name) $($_.Exception.Message)"
        continue
      }
      throw
    }
    $h = (Get-FileHash $out -Algorithm SHA256).Hash.ToLower()
    if ($a.Sha -and $h -ne $a.Sha.ToLower()) {
      Write-Host ("  [FAIL] {0}`n         期望 {1}`n         实际 {2}" -f $a.Name, $a.Sha, $h) -ForegroundColor Red
      $fail += $a.Name
    } else {
      Write-Host ("  [OK  ] {0}  {1:N1} MB" -f $a.Name, ((Get-Item $out).Length/1MB)) -ForegroundColor Green
      Log-To 'download.log' "OK $($a.Name) $h"
    }
  }
}

Write-Host ""
Get-ChildItem $DL_DIR | Select-Object Name, @{n='MB';e={[math]::Round($_.Length/1MB,2)}} | Format-Table -AutoSize

if ($fail.Count -gt 0) { throw ("以下文件校验失败，先别往下走：" + ($fail -join ', ')) }
Write-Step "全部产物就绪"
