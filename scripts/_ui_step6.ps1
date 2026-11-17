# _ui_step6.ps1 — 点 MuMu 主程序 EULA 的"接受"，并截图
$LOG='D:\pao\log\ui-step6.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Runtime.InteropServices;
public class U6{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint f);
}
"@
function Shot($h,$n){
  $r=New-Object U6+R; [void][U6]::GetWindowRect($h,[ref]$r); $w=$r.Rr-$r.L; $ht=$r.B-$r.T
  if($w -le 0){ L "skip $n"; return }
  $bmp=New-Object System.Drawing.Bitmap $w,$ht; $g=[System.Drawing.Graphics]::FromImage($bmp); $hdc=$g.GetHdc()
  [void][U6]::PrintWindow($h,$hdc,2); $g.ReleaseHdc($hdc)
  $bmp.Save("D:\pao\out\$n.png",[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); L "shot $n ${w}x${ht}"
}
function Click($x,$y){ [void][U6]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 300
  [void][U6]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 80
  [void][U6]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 700 }
$p=Get-Process MuMuNxMain -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if(-not $p){ L 'no MuMuNxMain window'; exit 1 }
$h=$p.MainWindowHandle
[void][U6]::SetForegroundWindow($h); Start-Sleep 1
Shot $h 'mumu-eula'
$r=New-Object U6+R; [void][U6]::GetWindowRect($h,[ref]$r)
Click ($r.L+263) ($r.T+403)
L 'clicked 接受'
Start-Sleep 6
Shot $h 'mumu-after-accept'
L 'DONE'
