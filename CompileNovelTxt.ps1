param(
    [string]$DraftsPath = ".\Manuscript\Novel\Drafts",
    [string]$OutputPath = ".\Manuscript\Novel\Compiled\Ascension - Compiled Draft.txt",
    [switch]$IncludePrequel
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-NameSortKey {
    param([string]$Name)

    # Expected chapter filename pattern: "10 - Chapter Title.txt" or "09A - Interlude.txt"
    $m = [regex]::Match($Name, '^(?<num>\d+)(?<suffix>[A-Za-z]?)\s*-\s*(?<title>.+)\.txt$')
    if ($m.Success) {
        return [PSCustomObject]@{
            Matched = $true
            Number  = [int]$m.Groups['num'].Value
            Suffix  = $m.Groups['suffix'].Value
            Name    = $Name
        }
    }

    return [PSCustomObject]@{
        Matched = $false
        Number  = [int]::MaxValue
        Suffix  = ""
        Name    = $Name
    }
}

if (-not (Test-Path -LiteralPath $DraftsPath)) {
    throw "Drafts path not found: $DraftsPath"
}

$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$partDirs = Get-ChildItem -Path $DraftsPath -Directory |
    Where-Object { $_.Name -match '^Part\s+\d+$' } |
    Sort-Object { [int]($_.Name -replace '^Part\s+', '') }

$compileSections = @()

if ($IncludePrequel.IsPresent) {
    $prequelPath = Join-Path $DraftsPath "Prequel\Invaders.txt"
    if (Test-Path -LiteralPath $prequelPath) {
        $prequelText = [System.IO.File]::ReadAllText((Resolve-Path $prequelPath))
        $compileSections += @(
            "PREQUEL: Invaders",
            "",
            $prequelText.TrimEnd(),
            "",
            ("=" * 80),
            ""
        )
    }
}

foreach ($partDir in $partDirs) {
    $chapterFiles = Get-ChildItem -Path $partDir.FullName -File -Filter "*.txt" |
        Sort-Object `
            @{ Expression = { (Get-NameSortKey $_.Name).Number } }, `
            @{ Expression = { (Get-NameSortKey $_.Name).Suffix } }, `
            @{ Expression = { (Get-NameSortKey $_.Name).Name } }

    if ($chapterFiles.Count -eq 0) { continue }

    $compileSections += @(
        $partDir.Name.ToUpper(),
        ("-" * 80),
        ""
    )

    foreach ($chapter in $chapterFiles) {
        $chapterText = [System.IO.File]::ReadAllText($chapter.FullName)
        $chapterTitle = [System.IO.Path]::GetFileNameWithoutExtension($chapter.Name)

        $compileSections += @(
            $chapterTitle,
            "",
            $chapterText.TrimEnd(),
            "",
            ("=" * 80),
            ""
        )
    }
}

$finalText = ($compileSections -join "`r`n").TrimEnd() + "`r`n"
[System.IO.File]::WriteAllText($OutputPath, $finalText, [System.Text.UTF8Encoding]::new($false))

Write-Host "Compile complete."
Write-Host "Output: $OutputPath"
