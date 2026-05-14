<#
.SYNOPSIS
    将 Markdown 分析报告导出为 PDF 或 Word 文档

.DESCRIPTION
    使用 Pandoc 将 Markdown 格式的股票分析报告转换为 PDF（需要 XeLaTeX）或 Word（.docx）。
    如果 Pandoc 未安装，则提供备用方案说明。

.PARAMETER InputFile
    输入的 Markdown 文件路径（必需）

.PARAMETER OutputFormat
    导出格式：'pdf'、'docx' 或 'both'（默认：both）

.PARAMETER OutputDir
    输出目录（默认：与输入文件相同目录）

.EXAMPLE
    .\export-report.ps1 -InputFile "G:\CS\AI\AAA\德明利(001309)深度分析报告_20260515.md"
    .\export-report.ps1 -InputFile "report.md" -OutputFormat pdf
    .\export-report.ps1 -InputFile "report.md" -OutputFormat both -OutputDir "G:\Reports"

.NOTES
    依赖：Pandoc（https://pandoc.org）
    PDF导出还需要：MiKTeX 或 TeX Live（提供 xelatex 引擎）
    版本：1.0 | snow-finance-cn skill
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "输入的Markdown文件路径")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$InputFile,

    [Parameter(Mandatory = $false)]
    [ValidateSet('pdf', 'docx', 'both')]
    [string]$OutputFormat = 'both',

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = ''
)

# ─── 初始化 ───────────────────────────────────────────────────────────────────

$ErrorActionPreference = 'Stop'
$inputPath  = Resolve-Path $InputFile
$baseName   = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
$sourceDir  = Split-Path $inputPath -Parent
$targetDir  = if ($OutputDir) { $OutputDir } else { $sourceDir }

# 确保输出目录存在
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Host "已创建输出目录：$targetDir" -ForegroundColor Cyan
}

$pdfPath  = Join-Path $targetDir "${baseName}.pdf"
$docxPath = Join-Path $targetDir "${baseName}.docx"

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  snow-finance-cn 报告导出工具" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  输入文件：$inputPath"
Write-Host "  导出格式：$OutputFormat"
Write-Host "  输出目录：$targetDir"
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# ─── 检查 Pandoc ───────────────────────────────────────────────────────────────

$pandocCmd = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandocCmd) {
    Write-Host "❌ 未检测到 Pandoc，无法自动导出。" -ForegroundColor Red
    Write-Host ""
    Write-Host "请选择以下备用方案之一：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "方案A：安装 Pandoc（推荐）" -ForegroundColor Green
    Write-Host "  1. 访问 https://pandoc.org/installing.html 下载安装包"
    Write-Host "  2. PDF 导出还需要 MiKTeX：https://miktex.org/download"
    Write-Host "  3. 安装完成后重新运行本脚本"
    Write-Host ""
    Write-Host "方案B：使用 VS Code 插件（仅PDF）" -ForegroundColor Green
    Write-Host "  1. 在 VS Code 扩展市场搜索 'Markdown PDF'"
    Write-Host "  2. 安装 yzane.markdown-pdf 插件"
    Write-Host "  3. 打开 .md 文件，右键选择 'Markdown PDF: Export (pdf)'"
    Write-Host ""
    Write-Host "方案C：浏览器打印（仅PDF）" -ForegroundColor Green
    Write-Host "  1. 在 VS Code 中预览 Markdown（Ctrl+Shift+V）"
    Write-Host "  2. 或用浏览器打开预览，Ctrl+P 选择'另存为PDF'"
    Write-Host ""
    exit 1
}

$pandocVersion = & pandoc --version 2>&1 | Select-Object -First 1
Write-Host "✅ 检测到 Pandoc：$pandocVersion" -ForegroundColor Green
Write-Host ""

# ─── PDF 导出 ────────────────────────────────────────────────────────────────

function Export-PDF {
    param([string]$src, [string]$dst)

    Write-Host "📄 正在导出 PDF..." -ForegroundColor Cyan

    # 检查 xelatex 是否可用
    $xelatex = Get-Command xelatex -ErrorAction SilentlyContinue
    if (-not $xelatex) {
        Write-Host "⚠️  未检测到 xelatex（需要 MiKTeX 或 TeX Live）。" -ForegroundColor Yellow
        Write-Host "   将尝试使用默认 PDF 引擎（不支持中文字体）..." -ForegroundColor Yellow
        Write-Host "   建议安装 MiKTeX：https://miktex.org/download" -ForegroundColor Yellow
        Write-Host ""

        # 使用默认引擎（可能中文乱码）
        $args = @(
            $src,
            '-o', $dst,
            '--standalone',
            '-V', 'geometry:margin=2cm',
            '--toc'
        )
    } else {
        Write-Host "✅ 检测到 xelatex，使用中文字体支持..." -ForegroundColor Green

        # 尝试常见中文字体
        $cjkFont = '微软雅黑'
        $fontTest = & fc-list ':lang=zh' 2>&1
        if ($fontTest -match '华文宋体') { $cjkFont = '华文宋体' }
        elseif ($fontTest -match '思源宋体') { $cjkFont = 'Source Han Serif CN' }

        $args = @(
            $src,
            '-o', $dst,
            '--pdf-engine=xelatex',
            '-V', "CJKmainfont=$cjkFont",
            '-V', 'geometry:margin=2cm',
            '-V', 'fontsize=11pt',
            '--standalone',
            '--toc',
            '--highlight-style=tango'
        )
    }

    try {
        & pandoc @args
        if ($LASTEXITCODE -eq 0) {
            $size = [math]::Round((Get-Item $dst).Length / 1KB, 1)
            Write-Host "✅ PDF 导出成功：$dst（${size} KB）" -ForegroundColor Green
        } else {
            Write-Host "❌ PDF 导出失败，退出码：$LASTEXITCODE" -ForegroundColor Red
            Write-Host "   提示：请检查是否安装了 MiKTeX 并已配置中文字体包" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ PDF 导出异常：$($_.Exception.Message)" -ForegroundColor Red
    }
}

# ─── Word 导出 ───────────────────────────────────────────────────────────────

function Export-Word {
    param([string]$src, [string]$dst)

    Write-Host "📝 正在导出 Word (.docx)..." -ForegroundColor Cyan

    $args = @(
        $src,
        '-o', $dst,
        '--standalone',
        '--toc',
        '--highlight-style=tango'
    )

    try {
        & pandoc @args
        if ($LASTEXITCODE -eq 0) {
            $size = [math]::Round((Get-Item $dst).Length / 1KB, 1)
            Write-Host "✅ Word 导出成功：$dst（${size} KB）" -ForegroundColor Green
        } else {
            Write-Host "❌ Word 导出失败，退出码：$LASTEXITCODE" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Word 导出异常：$($_.Exception.Message)" -ForegroundColor Red
    }
}

# ─── 执行导出 ────────────────────────────────────────────────────────────────

switch ($OutputFormat) {
    'pdf'  { Export-PDF  -src $inputPath -dst $pdfPath  }
    'docx' { Export-Word -src $inputPath -dst $docxPath }
    'both' {
        Export-PDF  -src $inputPath -dst $pdfPath
        Write-Host ""
        Export-Word -src $inputPath -dst $docxPath
    }
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  导出完成！" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan

# 显示输出文件列表
$outputs = @()
if ($OutputFormat -in @('pdf', 'both') -and (Test-Path $pdfPath)) {
    $outputs += "  📄 PDF  → $pdfPath"
}
if ($OutputFormat -in @('docx', 'both') -and (Test-Path $docxPath)) {
    $outputs += "  📝 Word → $docxPath"
}
if ($outputs.Count -gt 0) {
    $outputs | ForEach-Object { Write-Host $_ -ForegroundColor White }
} else {
    Write-Host "  ⚠️  未找到输出文件，请检查上方错误信息" -ForegroundColor Yellow
}
Write-Host ""
