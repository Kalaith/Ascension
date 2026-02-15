param(
    [Parameter(Mandatory = $false)]
    [string]$Path = ".\Manuscript\Novel\Drafts"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path not found: $Path"
}

$files = Get-ChildItem -LiteralPath $Path -Recurse -File -Filter "*.txt"
if (-not $files) {
    Write-Host "No .txt files found in: $Path"
    exit 0
}

$patternReplacements = @(
    @{ Pattern = '\bAlot\b'; Replace = 'A lot' },
    @{ Pattern = '\balot\b'; Replace = 'a lot' },
    @{ Pattern = '\bdiffrent\b'; Replace = 'different' },
    @{ Pattern = '\bDiffrent\b'; Replace = 'Different' },
    @{ Pattern = '\bgranmother\b'; Replace = 'grandmother' },
    @{ Pattern = '\bGranmother\b'; Replace = 'Grandmother' },
    @{ Pattern = '\bfinially\b'; Replace = 'finally' },
    @{ Pattern = '\bFinially\b'; Replace = 'Finally' },
    @{ Pattern = '\bstrenght\b'; Replace = 'strength' },
    @{ Pattern = '\bStrenght\b'; Replace = 'Strength' },
    @{ Pattern = '\bstrat\b'; Replace = 'start' },
    @{ Pattern = '\bStrat\b'; Replace = 'Start' },
    @{ Pattern = '\bAlcuion\b'; Replace = 'Alcuin' },
    @{ Pattern = '\balcuion\b'; Replace = 'alcuin' },
    @{ Pattern = '\bascenant\b'; Replace = 'ascendant' },
    @{ Pattern = '\bAscenant\b'; Replace = 'Ascendant' },
    @{ Pattern = '\byounsters\b'; Replace = 'youngsters' },
    @{ Pattern = '\bYounsters\b'; Replace = 'Youngsters' },
    @{ Pattern = '\binhabinets\b'; Replace = 'inhabitants' },
    @{ Pattern = '\bInhabinets\b'; Replace = 'Inhabitants' },
    @{ Pattern = '\btargetted\b'; Replace = 'targeted' },
    @{ Pattern = '\bTargetted\b'; Replace = 'Targeted' },
    @{ Pattern = '\bgatered\b'; Replace = 'gathered' },
    @{ Pattern = '\bGatered\b'; Replace = 'Gathered' },
    @{ Pattern = '\btoghter\b'; Replace = 'together' },
    @{ Pattern = '\bToghter\b'; Replace = 'Together' },
    @{ Pattern = '\blikley\b'; Replace = 'likely' },
    @{ Pattern = '\bLikley\b'; Replace = 'Likely' },
    @{ Pattern = '\bevenm\b'; Replace = 'even' },
    @{ Pattern = '\bEvenm\b'; Replace = 'Even' },
    @{ Pattern = '\blabratory\b'; Replace = 'laboratory' },
    @{ Pattern = '\bLabratory\b'; Replace = 'Laboratory' },
    @{ Pattern = '\bregnoize\b'; Replace = 'recognize' },
    @{ Pattern = '\bRegnoize\b'; Replace = 'Recognize' },
    @{ Pattern = '\basendant\b'; Replace = 'ascendant' },
    @{ Pattern = '\bAsendant\b'; Replace = 'Ascendant' },
    @{ Pattern = '\bcovoered\b'; Replace = 'covered' },
    @{ Pattern = '\bCovoered\b'; Replace = 'Covered' },
    @{ Pattern = '\bcntrol\b'; Replace = 'control' },
    @{ Pattern = '\bCntrol\b'; Replace = 'Control' },
    @{ Pattern = '\bresuce\b'; Replace = 'rescue' },
    @{ Pattern = '\bResuce\b'; Replace = 'Rescue' },
    @{ Pattern = '\bonces\b'; Replace = 'ones' },
    @{ Pattern = '\bOnces\b'; Replace = 'Ones' },
    @{ Pattern = '\bcompletly\b'; Replace = 'completely' },
    @{ Pattern = '\bCompletly\b'; Replace = 'Completely' },
    @{ Pattern = '\bbanquent\b'; Replace = 'banquet' },
    @{ Pattern = '\bBanquent\b'; Replace = 'Banquet' },
    @{ Pattern = '\bresecpect\b'; Replace = 'respect' },
    @{ Pattern = '\bResecpect\b'; Replace = 'Respect' },
    @{ Pattern = '\bapperitite\b'; Replace = 'appetite' },
    @{ Pattern = '\bApperitite\b'; Replace = 'Appetite' },
    @{ Pattern = '\breleif\b'; Replace = 'relief' },
    @{ Pattern = '\bReleif\b'; Replace = 'Relief' },
    @{ Pattern = '\bextravent\b'; Replace = 'extravagant' },
    @{ Pattern = '\bExtravent\b'; Replace = 'Extravagant' },
    @{ Pattern = '\bcleanests\b'; Replace = 'cleanest' },
    @{ Pattern = '\bCleanests\b'; Replace = 'Cleanest' },
    @{ Pattern = '\battactive\b'; Replace = 'attractive' },
    @{ Pattern = '\bAttactive\b'; Replace = 'Attractive' },
    @{ Pattern = '\bfosuced\b'; Replace = 'focused' },
    @{ Pattern = '\bFosuced\b'; Replace = 'Focused' },
    @{ Pattern = '\breleaized\b'; Replace = 'realized' },
    @{ Pattern = '\bReleaized\b'; Replace = 'Realized' },
    @{ Pattern = '\bdarked\b'; Replace = 'darkened' },
    @{ Pattern = '\bDarked\b'; Replace = 'Darkened' },
    @{ Pattern = '\bIve\b'; Replace = "I've" },
    @{ Pattern = '\bive\b'; Replace = "I've" },
    @{ Pattern = '\bIm\b'; Replace = "I'm" },
    @{ Pattern = '\bim\b'; Replace = "I'm" },
    @{ Pattern = '\bthats\b'; Replace = "that's" },
    @{ Pattern = '\bThats\b'; Replace = "That's" },
    @{ Pattern = '\blets\b'; Replace = "let's" },
    @{ Pattern = '\bLets\b'; Replace = "Let's" },
    @{ Pattern = '\bdont\b'; Replace = "don't" },
    @{ Pattern = '\bDont\b'; Replace = "Don't" },
    @{ Pattern = '\bdoesnt\b'; Replace = "doesn't" },
    @{ Pattern = '\bDoesnt\b'; Replace = "Doesn't" },
    @{ Pattern = '\bdidnt\b'; Replace = "didn't" },
    @{ Pattern = '\bDidnt\b'; Replace = "Didn't" },
    @{ Pattern = '\bcant\b'; Replace = "can't" },
    @{ Pattern = '\bCant\b'; Replace = "Can't" },
    @{ Pattern = '\bcouldnt\b'; Replace = "couldn't" },
    @{ Pattern = '\bCouldnt\b'; Replace = "Couldn't" },
    @{ Pattern = '\bwouldnt\b'; Replace = "wouldn't" },
    @{ Pattern = '\bWouldnt\b'; Replace = "Wouldn't" },
    @{ Pattern = '\bshouldnt\b'; Replace = "shouldn't" },
    @{ Pattern = '\bShouldnt\b'; Replace = "Shouldn't" },
    @{ Pattern = '\bwont\b'; Replace = "won't" },
    @{ Pattern = '\bWont\b'; Replace = "Won't" },
    @{ Pattern = '\bisnt\b'; Replace = "isn't" },
    @{ Pattern = '\bIsnt\b'; Replace = "Isn't" },
    @{ Pattern = '\barent\b'; Replace = "aren't" },
    @{ Pattern = '\bArent\b'; Replace = "Aren't" },
    @{ Pattern = '\bwasnt\b'; Replace = "wasn't" },
    @{ Pattern = '\bWasnt\b'; Replace = "Wasn't" },
    @{ Pattern = '\bwerent\b'; Replace = "weren't" },
    @{ Pattern = '\bWerent\b'; Replace = "Weren't" },
    @{ Pattern = '\bhavent\b'; Replace = "haven't" },
    @{ Pattern = '\bHavent\b'; Replace = "Haven't" },
    @{ Pattern = '\bhasnt\b'; Replace = "hasn't" },
    @{ Pattern = '\bHasnt\b'; Replace = "Hasn't" },
    @{ Pattern = '\bhadnt\b'; Replace = "hadn't" },
    @{ Pattern = '\bHadnt\b'; Replace = "Hadn't" },
    @{ Pattern = '\byoure\b'; Replace = "you're" },
    @{ Pattern = '\bYoure\b'; Replace = "You're" },
    @{ Pattern = '\btheyre\b'; Replace = "they're" },
    @{ Pattern = '\bTheyre\b'; Replace = "They're" },
    @{ Pattern = '\btheres\b'; Replace = "there's" },
    @{ Pattern = '\bTheres\b'; Replace = "There's" },
    @{ Pattern = '\boppsite\b'; Replace = "opposite" },
    @{ Pattern = '\bOppsite\b'; Replace = "Opposite" },
    @{ Pattern = '\btommrow\b'; Replace = "tomorrow" },
    @{ Pattern = '\bTommrow\b'; Replace = "Tomorrow" },
    @{ Pattern = '\bconfortable\b'; Replace = "comfortable" },
    @{ Pattern = '\bConfortable\b'; Replace = "Comfortable" },
    @{ Pattern = '\bnateruals\b'; Replace = "naturals" },
    @{ Pattern = '\bNateruals\b'; Replace = "Naturals" },
    @{ Pattern = '\bextremly\b'; Replace = "extremely" },
    @{ Pattern = '\bExtremly\b'; Replace = "Extremely" },
    @{ Pattern = '\bexhasuted\b'; Replace = "exhausted" },
    @{ Pattern = '\bExhasuted\b'; Replace = "Exhausted" },
    @{ Pattern = '\bdid did\b'; Replace = "did" }
)

$fileChanges = @()
$totalReplacements = 0

foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    if ($null -eq $text) { $text = "" }
    $original = $text
    $countForFile = 0

    foreach ($rule in $patternReplacements) {
        $updated = [System.Text.RegularExpressions.Regex]::Replace($text, $rule.Pattern, $rule.Replace)
        if ($updated -ne $text) {
            $matches = [System.Text.RegularExpressions.Regex]::Matches($text, $rule.Pattern).Count
            $countForFile += $matches
            $totalReplacements += $matches
            $text = $updated
        }
    }

    if ($text -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $text, [System.Text.Encoding]::UTF8)
        $fileChanges += [PSCustomObject]@{
            File = $file.FullName
            Replacements = $countForFile
        }
    }
}

Write-Host "Files changed: $($fileChanges.Count)"
Write-Host "Total replacements: $totalReplacements"
$fileChanges | Sort-Object Replacements -Descending | Format-Table -AutoSize
