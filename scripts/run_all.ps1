# ============================================================
#  run_all.ps1  —  一条命令串完 01→05（每步带停顿）
#  用法（管理员 PowerShell）：
#     cd D:\pao\scripts ; .\run_all.ps1
# ============================================================
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'config.ps1')

Write-Host @"
=====================================================
  校园跑 · MuMu 6.0 安卓15 部署流水线
  根目录 $PAO_ROOT   adb $MUMU_ADB
  目标包 $TARGET_PKG ($TARGET_ALIAS)
=====================================================
"@ -ForegroundColor Cyan

$steps = @(
  @{ n='00_download.ps1'; d='下载并校验 7 个产物（约 160 MB）' }
  @{ n='01_connect.ps1';  d='连接 MuMu 实例 + 确认 KernelSU root' }
  @{ n='02_modules.ps1';  d='装 ZygiskNext → Vector → Shamiko（含 3 次重启）' }
  @{ n='03_apps.ps1';     d='装 随心跑 / LocationSpoofer / HMA + 查 ABI' }
  @{ n='04_hide.ps1';     d='环境隐藏 + UI 清单' }
  @{ n='05_verify.ps1';   d='全链路验收 + 截图' }
)

foreach ($s in $steps) {
  Write-Host ""
  Write-Host ("--- {0}  {1}" -f $s.n, $s.d) -ForegroundColor Yellow
  Read-Host "    回车开始（Ctrl+C 退出）"
  & (Join-Path $PSScriptRoot $s.n)
  if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "$($s.n) 退出码 $LASTEXITCODE" }
}

Write-Host ""
Write-Host "流水线完成。最后按 VOD-EFFECT.md 的参数跑一遍，核对 6 条人工验收项。" -ForegroundColor Green
