# ============================================================
#  _ui_step1.ps1  —  清场 + 重开下载器 + 点"更改路径"，截图为证
#  需管理员运行（与安装器同权限，输入注入才不被 UIPI 拦）
# ============================================================
$ErrorActionPreference='Continue'
$LOG='D:\pao\log\ui-step1.log'
function L($m){ $s="[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m; Add-Content $LOG $s -Encoding UTF8 }

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Runtime.InteropServices;
public class U{
 [StructLayout(LayoutKind.Sequential)] public struct R{public int L,T,Rr,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint f);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
}
"@
function Click($x,$y){
  [void][U]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 250
  [void][U]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero)
  Start-Sleep -Milliseconds 60
  [void][U]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero)
  Start-Sleep -Milliseconds 400
  L "click $x,$y"
}
function Shot($h,$name){
  $r=New-Object U+R; [void][U]::GetWindowRect($h,[ref]$r)
  $w=$r.Rr-$r.L; $ht=$r.B-$r.T
  if($w -le 0){ L "shot skip $name"; return }
  $bmp=New-Object System.Drawing.Bitmap $w,$ht
  $g=[System.Drawing.Graphics]::FromImage($bmp); $hdc=$g.GetHdc()
  $ok=[U]::PrintWindow($h,$hdc,2); $g.ReleaseHdc($hdc)
  if(-not $ok){ $g.CopyFromScreen($r.L,$r.T,0,0,(New-Object System.Drawing.Size $w,$ht)) }
  $p="D:\pao\out\$name.png"; $bmp.Save($p,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  L "shot $name rect=$($r.L),$($r.T) ${w}x${ht}"
}

L '=== 清场 ==='
Get-Process | Where-Object { $_.ProcessName -match 'nemu-downloader|MuMu_6|MuMu-setup|nemu' } | ForEach-Object { L "kill $($_.ProcessName) $($_.Id)"; try{ Stop-Process -Id $_.Id -Force -ErrorAction Stop }catch{ L "  kill fail: $($_.Exception.Message)" } }
Start-Sleep 3

L '=== 重开下载器 ==='
Start-Process -FilePath 'D:\pao\dl\MuMu_6.0.4_gw-win_zh-Hans_1791433010.exe' | Out-Null
$h=[IntPtr]::Zero
for($i=0;$i -lt 30;$i++){
  Start-Sleep 2
  $p=Get-Process nemu-downloader -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
  if($p){ $h=$p.MainWindowHandle; L "window pid=$($p.Id) title=$($p.MainWindowTitle) h=$h"; break }
}
if($h -eq [IntPtr]::Zero){ L 'NO WINDOW'; exit 1 }
Start-Sleep 4
Shot $h 'ui-1-main'
[void][U]::SetForegroundWindow($h); Start-Sleep 1

# "更改路径" 按钮：相对窗口 (473,292)
$r=New-Object U+R; [void][U]::GetWindowRect($h,[ref]$r)
Click ($r.L+473) ($r.T+292)
Start-Sleep 3
Shot $h 'ui-2-after-changepath'

L '=== 枚举新窗口 ==='
Add-Type @"
using System;using System.Text;using System.Runtime.InteropServices;
public class EW{
 public delegate bool Cb(IntPtr h,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(Cb c,IntPtr l);
 [DllImport("user32.dll")] public static extern int GetWindowTextW(IntPtr h,StringBuilder s,int m);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h,out int p);
 [DllImport("user32.dll")] public static extern int GetClassNameW(IntPtr h,StringBuilder s,int m);
}
"@
$found=@()
$cb=[EW+Cb]{ param($hh,$ll)
  if([EW]::IsWindowVisible($hh)){
    $sb=New-Object System.Text.StringBuilder 512; [void][EW]::GetWindowTextW($hh,$sb,512)
    $cn=New-Object System.Text.StringBuilder 256; [void][EW]::GetClassNameW($hh,$cn,256)
    $pp=0; [void][EW]::GetWindowThreadProcessId($hh,[ref]$pp)
    $pn=(Get-Process -Id $pp -ErrorAction SilentlyContinue).ProcessName
    if($pn -match 'nemu|MuMu'){ $script:found += [pscustomobject]@{H=$hh;Pid=$pp;Proc=$pn;Title=$sb.ToString();Class=$cn.ToString()} }
  }
  return $true }
[void][EW]::EnumWindows($cb,[IntPtr]::Zero)
$found | ForEach-Object { L ("win pid=$($_.Pid) proc=$($_.Proc) class=$($_.Class) title='$($_.Title)' h=$($_.H)") }
$dlg = $found | Where-Object { $_.H -ne $h -and $_.Title } | Select-Object -First 1
if($dlg){ Shot ([IntPtr]$dlg.H) 'ui-3-path-dialog' } else { L 'no dialog found' }
L '=== DONE ==='
