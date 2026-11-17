# _ui_step10.ps1 — 用实测绝对坐标点：防火墙允许 → MuMu 接受 → 联想允许
$LOG='D:\pao\log\ui-step10.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Runtime.InteropServices;
public class UA{
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern IntPtr WindowFromPoint(int x,int y);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h,System.Text.StringBuilder s,int m);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h,System.Text.StringBuilder s,int m);
}
"@
function ProbeClick($x,$y,$tag){
  $h=[UA]::WindowFromPoint($x,$y)
  $sb=New-Object System.Text.StringBuilder 256; [void][UA]::GetWindowTextW($h,$sb,256)
  $cn=New-Object System.Text.StringBuilder 128; [void][UA]::GetClassNameW($h,$cn,128)
  L ("[$tag] point $x,$y -> hwnd=$h class='$($cn.ToString())' title='$($sb.ToString())'")
  [void][UA]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 400
  [void][UA]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 120
  [void][UA]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 1200
}
function Shot($n){ $b=New-Object System.Drawing.Bitmap 1920,1080; $g=[System.Drawing.Graphics]::FromImage($b)
  $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size 1920,1080)); $b.Save("D:\pao\out\$n.png",[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $b.Dispose(); L "shot $n" }

ProbeClick 860 673 'firewall-allow'
Start-Sleep 2
ProbeClick 861 728 'eula-accept'
Start-Sleep 2
ProbeClick 1799 949 'guard-allow'
Start-Sleep 3
Shot 's10-final'
$mgr='D:\MuMu\MuMuPlayer-6.0\nx_main\MuMuManager.exe'
L ("info: " + (((& $mgr info -v all) -join '') -replace '\s+',' '))
L 'DONE'
