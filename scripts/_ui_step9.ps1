# _ui_step9.ps1 — 按句柄激活各对话框并点击（隐藏窗口运行）
$LOG='D:\pao\log\ui-step9.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Text;using System.Runtime.InteropServices;
public class U9{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr SetActiveWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 public delegate bool Cb(IntPtr h,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(Cb c,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h,out int p);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a,uint b,bool f);
 [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
}
"@
function Force($h){
  $ft=[U9]::GetCurrentThreadId(); $tt=[U9]::GetWindowThreadProcessId($h,[IntPtr]::Zero)
  [void][U9]::AttachThreadInput($ft,$tt,$true)
  [void][U9]::BringWindowToTop($h); [void][U9]::SetForegroundWindow($h); [void][U9]::SetActiveWindow($h)
  [void][U9]::AttachThreadInput($ft,$tt,$false)
  Start-Sleep -Milliseconds 600
}
function Click($x,$y){ [void][U9]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 400
  [void][U9]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 120
  [void][U9]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 900; L "click $x,$y" }
function Shot($n){ $b=New-Object System.Drawing.Bitmap 1920,1080; $g=[System.Drawing.Graphics]::FromImage($b)
  $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size 1920,1080)); $b.Save("D:\pao\out\$n.png",[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $b.Dispose(); L "shot $n" }

function Get-Wins {
  $script:w=@()
  $cb=[U9+Cb]{ param($hh,$ll)
    if([U9]::IsWindowVisible($hh)){
      $sb=New-Object System.Text.StringBuilder 512; [void][U9]::GetWindowTextW($hh,$sb,512)
      $cn=New-Object System.Text.StringBuilder 256; [void][U9]::GetClassNameW($hh,$cn,256)
      $pp=0; [void][U9]::GetWindowThreadProcessId($hh,[ref]$pp)
      $script:w += [pscustomobject]@{H=$hh;Pid=$pp;Title=$sb.ToString();Class=$cn.ToString()}
    }; return $true }
  [void][U9]::EnumWindows($cb,[IntPtr]::Zero)
  return $script:w
}

$wins = Get-Wins
foreach($x in $wins){ if($x.Title -match '安全|防火墙|MuMu|发现|失败|提示'){ L ("win class='$($x.Class)' title='$($x.Title)' pid=$($x.Pid)") } }

# 1) 防火墙
$fw = $wins | Where-Object { $_.Class -eq 'Shell_SystemDialogProxy' } | Select-Object -First 1
if($fw){
  $r=New-Object U9+R; [void][U9]::GetWindowRect([IntPtr]$fw.H,[ref]$r)
  $bw=$r.Rr-$r.L; $bh=$r.B-$r.T
  L "firewall rect=$($r.L),$($r.T) ${bw}x${bh}"
  Force ([IntPtr]$fw.H)
  Click ($r.L + [int]($bw*0.35)) ($r.T + $bh - 48)
  Start-Sleep 3
  Shot 's9-a'
}
# 2) 联想安装拦截
$wins = Get-Wins
$guard = $wins | Where-Object { $_.Title -match '发现MuMu模拟器' } | Select-Object -First 1
if($guard){
  $r=New-Object U9+R; [void][U9]::GetWindowRect([IntPtr]$guard.H,[ref]$r)
  $bw=$r.Rr-$r.L; $bh=$r.B-$r.T
  L "guard rect=$($r.L),$($r.T) ${bw}x${bh}"
  Force ([IntPtr]$guard.H)
  Click ($r.L + [int]($bw*0.86)) ($r.T + $bh - 32)
  Start-Sleep 2
  Shot 's9-b'
} else { L 'no guard window' }
# 3) 下载器失败框
$wins = Get-Wins
$err = $wins | Where-Object { $_.Title -eq '失败' } | Select-Object -First 1
if($err){
  $r=New-Object U9+R; [void][U9]::GetWindowRect([IntPtr]$err.H,[ref]$r)
  L "err rect=$($r.L),$($r.T)"
  Force ([IntPtr]$err.H)
  Click ($r.L + 100) ($r.T + 30)   # 右上关闭
  Start-Sleep 2
  Shot 's9-c'
} else { L 'no error window' }
# 4) MuMu 主窗 EULA
$wins = Get-Wins
$mumu = $wins | Where-Object { $_.Class -eq 'Qt5156QWindowIcon' -and $_.Title -match 'MuMu' } | Select-Object -First 1
if($mumu){
  $r=New-Object U9+R; [void][U9]::GetWindowRect([IntPtr]$mumu.H,[ref]$r)
  L "mumu rect=$($r.L),$($r.T) $($r.Rr-$r.L)x$($r.B-$r.T)"
  Force ([IntPtr]$mumu.H)
  Click ($r.L+263) ($r.T+403)
  Start-Sleep 5
  Shot 's9-d'
} else { L 'no mumu main window' }

$mgr='D:\MuMu\MuMuPlayer-6.0\nx_main\MuMuManager.exe'
L ("info: " + (((& $mgr info -v all) -join '') -replace '\s+',' '))
L 'DONE'
