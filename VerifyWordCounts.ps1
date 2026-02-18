$files = Get-ChildItem "f:\Writing\AI\Ascension\Manuscript\Novel\Drafts\Part 3\*.txt", "f:\Writing\AI\Ascension\Manuscript\Novel\Drafts\Part 4\*.txt"
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $wordCount = ($content -split "\s+").Count
    Write-Output "$($file.Name): $wordCount"
}
