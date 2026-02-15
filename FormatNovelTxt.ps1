param(
    [string]$Path = ".\Manuscript\Novel",
    [switch]$NoRecurse,
    [switch]$FixMojibake,
    [switch]$RepairContractions
)

# Safe formatter for novel .txt files.
# - Preserves apostrophes and normal punctuation.
# - Removes trailing spaces.
# - Collapses repeated in-line spaces (keeps leading indentation).
# - Optional mojibake and missing-contraction repair.
# - Writes UTF-8 output.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-TextContent {
    param([string]$FilePath)

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes.Length -eq 0) { return "" }

    # BOM detection
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [System.Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return [System.Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
    }

    # No BOM: try UTF-8 first, then system default.
    $utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
    try {
        return $utf8Strict.GetString($bytes)
    }
    catch {
        return [System.Text.Encoding]::Default.GetString($bytes)
    }
}

function Repair-Contractions {
    param([string]$Line)

    $map = @{
        'didnt'   = "didn't";   'couldnt' = "couldn't"; 'wouldnt' = "wouldn't"; 'shouldnt' = "shouldn't"
        'dont'    = "don't";    'doesnt'  = "doesn't";  'isnt'    = "isn't";    'arent'    = "aren't"
        'wasnt'   = "wasn't";   'werent'  = "weren't";  'hasnt'   = "hasn't";   'havent'   = "haven't"
        'hadnt'   = "hadn't";   'wont'    = "won't";    'cant'    = "can't"
        'im'      = "I'm";      'ive'     = "I've"
        'youre'   = "you're";   'youve'   = "you've"
        'theyre'  = "they're";  'theyve'  = "they've"
    }

    $result = $Line
    foreach ($key in $map.Keys) {
        $value = $map[$key]
        $result = [regex]::Replace(
            $result,
            "(?<![A-Za-z])$key(?![A-Za-z])",
            {
                param($m)
                $w = $m.Value
                if ($w -cmatch '^[A-Z]+$') { return $value.ToUpper() }
                if ($w -cmatch '^[A-Z]') { return ($value.Substring(0,1).ToUpper() + $value.Substring(1)) }
                return $value
            },
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }

    return $result
}

function Format-Text {
    param(
        [string]$Text,
        [bool]$FixMojibakeEnabled,
        [bool]$RepairContractionsEnabled
    )

    $normalized = $Text -replace "`r`n", "`n" -replace "`r", "`n"
    $lines = $normalized -split "`n", -1

    $outLines = foreach ($line in $lines) {
        $l = $line.TrimEnd()
        # Collapse 2+ spaces only between non-space characters.
        $l = $l -replace '(?<=\S) {2,}(?=\S)', ' '

        if ($FixMojibakeEnabled) {
            # Optional common mojibake fixes caused by cp1252/utf8 mismatch.
            $l = $l -replace 'â€™', "'" -replace 'â€˜', "'" -replace 'â€œ', '"' -replace 'â€', '"'
        }

        if ($RepairContractionsEnabled) {
            $l = Repair-Contractions -Line $l
        }

        $l
    }

    return ($outLines -join "`r`n")
}

$recurse = -not $NoRecurse.IsPresent
$files = Get-ChildItem -Path $Path -Filter "*.txt" -File -Recurse:$recurse
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$changed = 0

foreach ($file in $files) {
    $original = Get-TextContent -FilePath $file.FullName
    $formatted = Format-Text -Text $original -FixMojibakeEnabled:$FixMojibake.IsPresent -RepairContractionsEnabled:$RepairContractions.IsPresent

    if ($formatted -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $formatted, $utf8NoBom)
        $changed++
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "Formatting complete. Files changed: $changed"
