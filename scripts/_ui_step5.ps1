# _ui_step5.ps1 — 用目录联接把安装目录实体放 D 盘，勾协议并开始安装（管理员运行）
$LOG='D:\pao\log\ui-step5.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Runtime.InteropServices;
public class U5{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint f);
}
"@
function Shot($h,$n){
  $r=New-Object U5+R; [void][U5]::GetWindowRect($h,[ref]$r); $w=$r.Rr-$r.L; $ht=$r.B-$r.T
  if($w -le 0){ return }
  $bmp=New-Object System.Drawing.Bitmap $w,$ht; $g=[System.Drawing.Graphics]::FromImage($bmp); $hdc=$g.GetHdc()
  [void][U5]::PrintWindow($h,$hdc,2); $g.ReleaseHdc($hdc)
  $p="D:\pao\out\$n.png"; $bmp.Save($p,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  L "shot $n"
}
function Click($x,$y){ [void][U5]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 300
  [void][U5]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 80
  [void][U5]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 600 }

# --- 目录联接：C:\Users\lenovo\MuMuPlayer -> D:\MuMu\MuMuPlayer-6.0 ---
$target='D:\MuMu\MuMuPlayer-6.0'
$link='C:\Users\lenovo\MuMuPlayer'
if(-not (Test-Path $target)){ New-Item -ItemType Directory -Path $target -Force | Out-Null; L "makedir $target" }
if(Test-Path $link){
  $it=Get-Item $link -Force
  if($it.LinkType -eq 'Junction'){ L "junction 已存在 -> $($it.Target)" }
  else {
    if((Get-ChildItem $link -Force -ErrorAction SilentlyContinue).Count -eq 0){ Remove-Item $link -Force; L 'removed empty dir' ; & cmd.exe /c "mklink /J `"$link`" `"$target`"" | Out-Null; L 'junction created' }
    else { L "WARN: $link 非空且非联接，跳过" }
  }
} else {
  & cmd.exe /c "mklink /J `"$link`" `"$target`"" | Out-Null
  L "junction created: $link -> $target"
}
L ("junction verify: " + ((Get-Item $link -Force).LinkType) + " -> " + ((Get-Item $link -Force).Target))

$p=Get-Process nemu-downloader | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if(-not $p){ L 'no downloader window'; exit 1 }
$h=$p.MainWindowHandle
[void][U5]::SetForegroundWindow($h); Start-Sleep 1
$r=New-Object U5+R; [void][U5]::GetWindowRect($h,[ref]$r)
L "rect=$($r.L),$($r.T)"

# 勾"我已阅读并同意"
Click ($r.L+37) ($r.T+415)
Start-Sleep 1
Shot $h 'ui-h-agreed'

# 点"立即安装"
Click ($r.L+320) ($r.T+328)
L 'clicked 立即安装'
Start-Sleep 5
Shot $h 'ui-i-installing'

# 监控安装进度
for($i=0;$i -lt 90;$i++){
  Start-Sleep 10
  $adb=Test-Path 'D:\MuMu\MuMuPlayer-6.0\shell\adb.exe'
  $sz=(Get-ChildItem $target -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
  $procs=(Get-Process | Where-Object { $_.ProcessName -match 'MuMu|nemu|setup' } | Select-Object -ExpandProperty ProcessName -Unique) -join ','
  L ("t={0}s adb={1} size={2:N0}MB procs=[{3}]" -f ($i*10),$adb,($sz/1MB),$procs)
  if($adb){ L 'INSTALL OK'; break }
  if(-not $procs){ L 'all installer processes gone'; break }
}
Shot $h 'ui-j-final'
L 'DONE'
