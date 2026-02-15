# PowerShell script to count words in the novel drafts under Manuscript\Novel\Drafts
# Outputs total words per part, per chapter, and for the entire novel

$draftsPath = ".\Manuscript\Novel\Drafts"

# Function to count words in a string
function Get-WordCount {
    param([string]$text)
    if ([string]::IsNullOrWhiteSpace($text)) { return 0 }
    # Normalize spaces and split
    $words = $text -replace '\s+', ' ' -split ' ' | Where-Object { $_ -ne '' }
    return $words.Count
}

# Get all .txt files recursively
$txtFiles = Get-ChildItem -Path $draftsPath -Recurse -Filter "*.txt"

# Group files by their parent directory (part)
$groupedByPart = $txtFiles | Group-Object { $_.Directory.Name }

$totalNovelWords = 0

Write-Host "Word Counts for Novel Drafts:"
Write-Host "=============================="

foreach ($partGroup in $groupedByPart) {
    $partName = $partGroup.Name
    $partWords = 0
    Write-Host "`nPart: $partName"
    Write-Host "Chapters:"
    
    foreach ($file in $partGroup.Group) {
        $content = Get-Content $file.FullName -Raw -Encoding Default
        $wordCount = Get-WordCount $content
        $partWords += $wordCount
        $chapterName = $file.Name
        Write-Host "  $chapterName : $wordCount words"
    }
    
    Write-Host "Total for $partName : $partWords words"
    $totalNovelWords += $partWords
}

Write-Host "`n=============================="
Write-Host "Total words in entire novel: $totalNovelWords words"