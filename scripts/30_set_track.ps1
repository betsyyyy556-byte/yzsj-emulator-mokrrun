# ============================================================
#  30_set_track.ps1  —  把起点/轨迹设成「假草运动场」400 m 跑道
#  说明：
#   - 运动世界的打卡点在跑道上，所以轨迹必须是跑道那一圈（椭圆），
#     不是校园环路。400 m × 5 圈 = 2 km，正好过 2.0 km 门槛。
#   - 本脚本写 Settings.Global（模块侧读这里）；App 界面里的起点存在
#     WebView 本地存储，脚本改不到，需要在 App 地图页拖一次确认。
#  用法： .\30_set_track.ps1
# ============================================================
$adb = 'D:\MuMu\MuMuPlayer-6.0\nx_device\15.0\shell\adb.exe'
$D   = '127.0.0.1:16384'

# --- 假草运动场（东莞理工学院松山湖校区田径场），GCJ-02 ---
$cLat = 22.906047
$cLng = 113.870808

# --- 400 m 标准跑道椭圆：直道 84.39 m + 半径 36.5 m ---
$mPerLat = 111320.0
$mPerLng = 111320.0 * [math]::Cos($cLat * [math]::PI / 180.0)
$a = 60.0   # 东西半轴（米）
$b = 37.0   # 南北半轴（米）

$pts = @()
for ($i = 0; $i -lt 8; $i++) {
  $th = $i * 45.0 * [math]::PI / 180.0
  $dx = $a * [math]::Cos($th)
  $dy = $b * [math]::Sin($th)
  $pts += [pscustomobject]@{
    lat = [math]::Round($cLat + $dy / $mPerLat, 7)
    lng = [math]::Round($cLng + $dx / $mPerLng, 7)
  }
}
$json = '[' + (($pts | ForEach-Object { '{"lat":' + $_.lat + ',"lng":' + $_.lng + '}' }) -join ',') + ']'
$b64  = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))

# 起跑线 = 椭圆最西点（跑道第 5 点）
$origin = '22.906047,113.8702229'
$cfg    = 'speed=2.4;cadence=2.7;stride=0.8888889;anti=1;spdmax=5.0;sat=14;qr=2;acc=0'

Write-Host "跑道中心 : $cLat, $cLng"
Write-Host "起跑线   : $origin"
Write-Host "环线点数 : $($pts.Count)  周长约 398 m（5 圈 = 1.99 km，跑 6 圈更保险）"
$pts | Format-Table -AutoSize

& $adb -s $D shell "settings put global mokr_origin '$origin'"
& $adb -s $D shell "settings put global mokr_config '$cfg'"
& $adb -s $D shell "settings put global mokr_route_b64 '$b64'"
& $adb -s $D shell "settings put global mokr_run 1"

Write-Host ''
Write-Host '已写入 Settings.Global，回读：' -ForegroundColor Green
& $adb -s $D shell "settings get global mokr_origin"
& $adb -s $D shell "settings get global mokr_run"

Write-Host @"

还差 App 里的两步（它的起点存在 WebView 本地存储，脚本改不到）：
  1) 随心跑 -> 修改起点 -> 把准星拖到跑道 -> 确定
  2) 绘制路线 -> 沿跑道点一圈（8 个点即可）-> 保存 -> 悬浮窗「开始」
跑起来后速度 2.4 m/s，400 m 一圈约 2 分 47 秒，6 圈 ≈ 16.7 分钟 / 2.4 km
"@ -ForegroundColor Cyan
