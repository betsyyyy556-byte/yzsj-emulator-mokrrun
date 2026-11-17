# _ui_step8.ps1 — 依次点掉防火墙允许 / 联想安装拦截允许 / 下载器失败框关闭
$LOG='D:\pao\log\ui-step8.log'
function L($m){ Add-Content $LOG ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'),$m) -Encoding UTF8 }
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;using System.Runtime.InteropServices;
public class U8{
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
}
"@
function Click($x,$y){ [void][U8]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 400
  [void][U8]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 100
  [void][U8]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero); Start-Sleep -Milliseconds 900; L "click $x,$y" }
function Shot($n){ $b=New-Object System.Drawing.Bitmap 1920,1080; $g=[System.Drawing.Graphics]::FromImage($b)
  $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size 1920,1080)); $b.Save("D:\pao\out\$n.png",[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $b.Dispose(); L "shot $n" }

Click 765 599          # 防火墙：允许
Start-Sleep 2
Shot 's8-a'
Click 1630 845         # 联想"发现MuMu模拟器..."：允许
Start-Sleep 2
Shot 's8-b'
Click 1306 424         # 下载器失败框：关闭
Start-Sleep 2
Shot 's8-c'
Click 883 721          # MuMu 主程序：接受（EULA）
Start-Sleep 4
Shot 's8-d'
$mgr='D:\MuMu\MuMuPlayer-6.0\nx_main\MuMuManager.exe'
L ("info: " + (((& $mgr info -v all) -join '') -replace '\s+',' '))
L 'DONE'
