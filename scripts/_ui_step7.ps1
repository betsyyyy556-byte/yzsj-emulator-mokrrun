# _ui_step7.ps1 — 允许防火墙 + 接受 EULA（管理员运行）
$LOG='D:\pao\log\ui-step7.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Text;using System.Runtime.InteropServices;
public class U7{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 public delegate bool Cb(IntPtr h,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(Cb c,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h,out int p);
}
"@
function Click($x,$y){ [void][U7]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 350
  [void][U7]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 90
  [void][U7]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 800; L "click $x,$y" }
function ScreenShot($n){
  $b=New-Object System.Drawing.Bitmap 1920,1080
  $g=[System.Drawing.Graphics]::FromImage($b); $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size 1920,1080))
  $b.Save("D:\pao\out\$n.png",[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $b.Dispose(); L "shot $n"
}
# 枚举窗口，找防火墙框和 MuMu 主窗
$wins=@()
$cb=[U7+Cb]{ param($hh,$ll)
  if([U7]::IsWindowVisible($hh)){
    $sb=New-Object System.Text.StringBuilder 512; [void][U7]::GetWindowTextW($hh,$sb,512)
    $cn=New-Object System.Text.StringBuilder 256; [void][U7]::GetClassNameW($hh,$cn,256)
    $pp=0; [void][U7]::GetWindowThreadProcessId($hh,[ref]$pp)
    $script:wins += [pscustomobject]@{H=$hh;Pid=$pp;Title=$sb.ToString();Class=$cn.ToString()}
  }; return $true }
[void][U7]::EnumWindows($cb,[IntPtr]::Zero)
foreach($w in $wins){ if($w.Title -match '安全|防火墙|MuMu'){ L ("win class=$($w.Class) title='$($w.Title)' pid=$($w.Pid)") } }

$fw = $wins | Where-Object { $_.Class -match '^#32770' -and $_.Title -match '安全|Security' } | Select-Object -First 1
if($fw){
  [void][U7]::SetForegroundWindow([IntPtr]$fw.H); Start-Sleep 1
  $r=New-Object U7+R; [void][U7]::GetWindowRect([IntPtr]$fw.H,[ref]$r)
  L "firewall dlg rect=$($r.L),$($r.T) $($r.Rr-$r.L)x$($r.B-$r.T)"
  # 允许按钮：对话框内左下按钮，约在 (宽*0.35, 高-45)
  $bw=$r.Rr-$r.L; $bh=$r.B-$r.T
  Click ($r.L + [int]($bw*0.35)) ($r.T + $bh - 45)
  Start-Sleep 2
} else { L 'no firewall dialog' }

$p=Get-Process MuMuNxMain | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if($p){
  $h=$p.MainWindowHandle
  [void][U7]::SetForegroundWindow($h); Start-Sleep 1
  $r=New-Object U7+R; [void][U7]::GetWindowRect($h,[ref]$r)
  L "mumu rect=$($r.L),$($r.T) $($r.Rr-$r.L)x$($r.B-$r.T)"
  Click ($r.L+263) ($r.T+403)
  Start-Sleep 6
}
ScreenShot 'mumu-after-eula'
$mgr='D:\MuMu\MuMuPlayer-6.0\nx_main\MuMuManager.exe'
$info=(& $mgr info -v all) -join ''
L ("info: " + ($info -replace '\s+',' '))
L 'DONE'
