# ============================================================
#  40_fix_vector_scope.ps1  —  重装模块后修复 Vector 启用状态与作用域
#  背景：用 adb install 覆盖/重装 com.mokrun.app 后，Vector 会把该模块
#        置为 enabled=0 且清空作用域，导致 hook 完全不注入（表现为
#        运动世界位置仍读系统定位、"不在有效区域内"）。
#  本脚本直接改 /data/adb/lspd/config/modules_config.db，改完重启实例即生效。
# ============================================================
$adb = 'D:\MuMu\MuMuPlayer-6.0\nx_device\15.0\shell\adb.exe'
$mgr = 'D:\MuMu\MuMuPlayer-6.0\nx_main\MuMuManager.exe'
$D   = '127.0.0.1:16384'
$MODULE = 'com.mokrun.app'
$TARGET = 'com.zjwh.android_wh_physicalfitness'
$DB     = '/data/adb/lspd/config/modules_config.db'

& $adb -s $D root | Out-Null
Start-Sleep 3
& $adb -s $D connect $D | Out-Null

# 取 mid
$mid = ((& $adb -s $D shell "sqlite3 $DB `"select mid from modules where module_pkg_name='$MODULE';`"") -join '').Trim()
if (-not $mid) { throw "Vector 数据库里没有 $MODULE，先在 Vector 里打开一次该模块" }
Write-Host "mid = $mid"

$sql = @"
update modules set enabled=1 where mid=$mid;
insert or replace into scope(mid,app_pkg_name,user_id) values($mid,'$TARGET',0);
select mid,module_pkg_name,enabled from modules;
select * from scope;
"@
Set-Content 'D:\pao\out\fix_scope.sql' -Value $sql -Encoding ASCII
& $adb -s $D push 'D:\pao\out\fix_scope.sql' /data/local/tmp/fix_scope.sql | Out-Null
& $adb -s $D shell "sqlite3 $DB < /data/local/tmp/fix_scope.sql"

Write-Host ''
Write-Host '现在重启实例，让 Vector daemon 重新读配置：' -ForegroundColor Yellow
& $mgr control -v 0 restart
Start-Sleep 25
for ($i=0; $i -lt 24; $i++) {
  Start-Sleep 5
  $o = ((& $mgr info -v 0) -join '') | ConvertFrom-Json
  if ($o.is_android_started) { Write-Host '实例已启动' -ForegroundColor Green; break }
}
& $adb -s $D connect $D | Out-Null
& $adb -s $D root | Out-Null
Write-Host '完成。接着在运动世界里进「校园跑」，位置应落在田径场圈上。' -ForegroundColor Green
