# _ui_step2.ps1 — 在已打开的下载器窗口上点"更改路径"，并把对话框截图（管理员运行）
$LOG='D:\pao\log\ui-step2.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Text;using System.Runtime.InteropServices;
public class U2{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint f);
 public delegate bool Cb(IntPtr h,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(Cb c,IntPtr l);
 [DllImport("user32.dll")] public static extern int GetWindowTextW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll")] public static extern int GetClassNameW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h,out int p);
}
"@
function Shot($h,$n){
  $r=New-Object U2+R; [void][U2]::GetWindowRect($h,[ref]$r); $w=$r.Rr-$r.L; $ht=$r.B-$r.T
  if($w -le 0){ L "shot skip $n"; return }
  $bmp=New-Object System.Drawing.Bitmap $w,$ht; $g=[System.Drawing.Graphics]::FromImage($bmp); $hdc=$g.GetHdc()
  $ok=[U2]::PrintWindow($h,$hdc,2); $g.ReleaseHdc($hdc)
  if(-not $ok){ $g.CopyFromScreen($r.L,$r.T,0,0,(New-Object System.Drawing.Size $w,$ht)) }
  $p="D:\pao\out\$n.png"; $bmp.Save($p,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  L "shot $n rect=$($r.L),$($r.T) ${w}x${ht}"
}
$p=Get-Process nemu-downloader -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if(-not $p){ L 'no window'; exit 1 }
$h=$p.MainWindowHandle
[void][U2]::SetForegroundWindow($h); Start-Sleep 1
Shot $h 'ui-a-before'
$r=New-Object U2+R; [void][U2]::GetWindowRect($h,[ref]$r)
$bx=$r.L+473; $by=$r.T+292
[void][U2]::SetCursorPos($bx,$by); Start-Sleep 1
[void][U2]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep 1
[void][U2]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep 3
L "clicked 更改路径 at $bx,$by"
Shot $h 'ui-b-after'
$found=@()
$cb=[U2+Cb]{ param($hh,$ll)
  if([U2]::IsWindowVisible($hh)){
    $sb=New-Object System.Text.StringBuilder 512; [void][U2]::GetWindowTextW($hh,$sb,512)
    $cn=New-Object System.Text.StringBuilder 256; [void][U2]::GetClassNameW($hh,$cn,256)
    $pp=0; [void][U2]::GetWindowThreadProcessId($hh,[ref]$pp)
    $pn=(Get-Process -Id $pp -ErrorAction SilentlyContinue).ProcessName
    if($pn -match 'nemu|MuMu|explorer'){ $script:found += [pscustomobject]@{H=$hh;Pid=$pp;Proc=$pn;Title=$sb.ToString();Class=$cn.ToString()} }
  }
  return $true }
[void][U2]::EnumWindows($cb,[IntPtr]::Zero)
$i=0
foreach($f in $found){ $i++; L ("win#$i pid=$($f.Pid) proc=$($f.Proc) class=$($f.Class) title='$($f.Title)' h=$($f.H)") }
$dlg = $found | Where-Object { $_.H -ne $h -and $_.Title } | Select-Object -First 1
if($dlg){ Shot ([IntPtr]$dlg.H) 'ui-c-dialog' }
L 'DONE'
