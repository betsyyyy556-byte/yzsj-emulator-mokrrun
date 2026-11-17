# _ui_step4.ps1 — 点"更改路径"，把路径改成 D:\MuMu\MuMuPlayer-6.0（管理员运行）
$LOG='D:\pao\log\ui-step4.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;using System.Text;using System.Runtime.InteropServices;
public class U4{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint f);
 public delegate bool Cb(IntPtr h,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(Cb c,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h,out int p);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
}
"@
function Shot($h,$n){
  $r=New-Object U4+R; [void][U4]::GetWindowRect($h,[ref]$r); $w=$r.Rr-$r.L; $ht=$r.B-$r.T
  if($w -le 0 -or $ht -le 0){ L "shot skip $n"; return }
  $bmp=New-Object System.Drawing.Bitmap $w,$ht; $g=[System.Drawing.Graphics]::FromImage($bmp); $hdc=$g.GetHdc()
  $ok=[U4]::PrintWindow($h,$hdc,2); $g.ReleaseHdc($hdc)
  if(-not $ok){ $g.CopyFromScreen($r.L,$r.T,0,0,(New-Object System.Drawing.Size $w,$ht)) }
  $p="D:\pao\out\$n.png"; $bmp.Save($p,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  L "shot $n rect=$($r.L),$($r.T) ${w}x${ht}"
}
function Click($x,$y){ [void][U4]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 300
  [void][U4]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 80
  [void][U4]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 600 }

$p=Get-Process nemu-downloader | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if(-not $p){ L 'no window'; exit 1 }
$h=$p.MainWindowHandle
[void][U4]::SetForegroundWindow($h); Start-Sleep 1
$r=New-Object U4+R; [void][U4]::GetWindowRect($h,[ref]$r)

Click ($r.L+473) ($r.T+292)
L 'clicked 更改路径'
Start-Sleep 3

# 找新增的顶层窗口（对话框）
$all=@()
$cb=[U4+Cb]{ param($hh,$ll)
  if([U4]::IsWindowVisible($hh)){
    $sb=New-Object System.Text.StringBuilder 512; [void][U4]::GetWindowTextW($hh,$sb,512)
    $cn=New-Object System.Text.StringBuilder 256; [void][U4]::GetClassNameW($hh,$cn,256)
    $pp=0; [void][U4]::GetWindowThreadProcessId($hh,[ref]$pp)
    $script:all += [pscustomobject]@{H=$hh;Pid=$pp;Title=$sb.ToString();Class=$cn.ToString()}
  }
  return $true }
[void][U4]::EnumWindows($cb,[IntPtr]::Zero)
$dlgs = $all | Where-Object { $_.H -ne $h -and $_.Class -match '^#32770|CabinetWClass|DirectUIHWND' }
foreach($d in $dlgs){ L ("dlg class=$($d.Class) title='$($d.Title)' h=$($d.H) pid=$($d.Pid)") }
$dlg = $dlgs | Select-Object -First 1

if($dlg){
  [void][U4]::SetForegroundWindow([IntPtr]$dlg.H); Start-Sleep 1
  Shot ([IntPtr]$dlg.H) 'ui-e-folder-dialog'
  Set-Clipboard -Value 'D:\MuMu\MuMuPlayer-6.0'
  Start-Sleep -Milliseconds 400
  [System.Windows.Forms.SendKeys]::SendWait('^v')
  Start-Sleep -Milliseconds 800
  Shot ([IntPtr]$dlg.H) 'ui-f-pasted'
  [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
  Start-Sleep 2
  [void][U4]::SetForegroundWindow($h); Start-Sleep 1
  Shot $h 'ui-g-after-path'
  L 'pasted + enter'
} else {
  L 'no dialog detected'
  Shot $h 'ui-e-none'
}
L 'DONE'
