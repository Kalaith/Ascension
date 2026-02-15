param(
    [Parameter(Mandatory = $false)]
    [string]$Path = ".",

    [Parameter(Mandatory = $false)]
    [string]$OutputRoot = ".\Manuscript\Exports\PlainText",

    [Parameter(Mandatory = $false)]
    [switch]$NoRecurse,

    [Parameter(Mandatory = $false)]
    [switch]$OverwriteTxt
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path not found: $Path"
}

$resolvedInputRoot = (Resolve-Path -LiteralPath $Path).Path
$resolvedOutputRoot = if ([System.IO.Path]::IsPathRooted($OutputRoot)) {
    [System.IO.Path]::GetFullPath($OutputRoot)
} else {
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $OutputRoot))
}
if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
    New-Item -ItemType Directory -Path $resolvedOutputRoot | Out-Null
}

$searchRecurse = -not $NoRecurse
$rtfFiles = Get-ChildItem -LiteralPath $Path -File -Filter "*.rtf" -Recurse:$searchRecurse

if (-not $rtfFiles) {
    Write-Host "No .rtf files found in: $Path"
    exit 0
}

$processed = 0
$skipped = 0

foreach ($file in $rtfFiles) {
    $relativeDir = $file.DirectoryName.Substring($resolvedInputRoot.Length).TrimStart('\')
    $targetDir = if ([string]::IsNullOrEmpty($relativeDir)) { $resolvedOutputRoot } else { Join-Path $resolvedOutputRoot $relativeDir }
    if (-not (Test-Path -LiteralPath $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }
    $outFile = Join-Path $targetDir ([System.IO.Path]::GetFileNameWithoutExtension($file.Name) + ".txt")

    if ((Test-Path -LiteralPath $outFile) -and -not $OverwriteTxt) {
        Write-Host "Skipping (exists): $outFile"
        $skipped++
        continue
    }

    $rtfContent = Get-Content -LiteralPath $file.FullName -Raw

    $rtb = New-Object System.Windows.Forms.RichTextBox
    try {
        $rtb.Rtf = $rtfContent
        $plainText = $rtb.Text
    }
    finally {
        $rtb.Dispose()
    }

    [System.IO.File]::WriteAllText($outFile, $plainText, [System.Text.Encoding]::UTF8)
    Write-Host "Converted: $($file.FullName) -> $outFile"
    $processed++
}

Write-Host ""
Write-Host "Done. Converted: $processed, Skipped: $skipped"
