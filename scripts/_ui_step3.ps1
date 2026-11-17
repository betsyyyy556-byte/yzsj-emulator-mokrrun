# _ui_step3.ps1 — 进入"自定义安装"页并截图（管理员运行）
$LOG='D:\pao\log\ui-step3.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Runtime.InteropServices;
public class U3{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint f);
}
"@
function Shot($h,$n){
  $r=New-Object U3+R; [void][U3]::GetWindowRect($h,[ref]$r); $w=$r.Rr-$r.L; $ht=$r.B-$r.T
  $bmp=New-Object System.Drawing.Bitmap $w,$ht; $g=[System.Drawing.Graphics]::FromImage($bmp); $hdc=$g.GetHdc()
  [void][U3]::PrintWindow($h,$hdc,2); $g.ReleaseHdc($hdc)
  $p="D:\pao\out\$n.png"; $bmp.Save($p,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  L "shot $n rect=$($r.L),$($r.T) ${w}x${ht}"
}
function Click($x,$y){ [void][U3]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 250
  [void][U3]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 80
  [void][U3]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 500 }
$p=Get-Process nemu-downloader | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if(-not $p){ L 'no window'; exit 1 }
$h=$p.MainWindowHandle
[void][U3]::SetForegroundWindow($h); Start-Sleep 1
$r=New-Object U3+R; [void][U3]::GetWindowRect($h,[ref]$r)
L "rect=$($r.L),$($r.T) size=$($r.Rr-$r.L)x$($r.B-$r.T)"
# "自定义安装 >" 在右下角
Click ($r.L+568) ($r.T+418)
Start-Sleep 2
Shot $h 'ui-d-custom'
L 'DONE'
