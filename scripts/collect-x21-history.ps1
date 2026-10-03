param(
    [string]$Root = 'D:\carlinkit\Carlinkit_aosp11',
    [string]$OutDir = '.\evidence\x21-sc162\history'
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$rootPath = (Resolve-Path $Root).Path
$inventory = Join-Path $OutDir 'file-inventory.tsv'
$textCandidates = Join-Path $OutDir 'text-candidates.txt'

"relative_path\tsize\tlast_write_utc\textension" | Set-Content -Encoding UTF8 $inventory

Get-ChildItem -LiteralPath $rootPath -Recurse -Force -File | ForEach-Object {
    $rel = $_.FullName.Substring($rootPath.Length).TrimStart('\')
    $safeRel = $rel -replace "`t", ' '
    "$safeRel`t$($_.Length)`t$($_.LastWriteTimeUtc.ToString('o'))`t$($_.Extension)" | Add-Content -Encoding UTF8 $inventory
}

$interesting = @(
    '.sh','.ps1','.bat','.cmd','.py','.pl','.rb',
    '.txt','.md','.log','.prop','.rc','.xml','.json','.mk','.bp','.conf','.cfg','.ini',
    '.te','.cil','.contexts','.list','.patch','.diff'
)

Get-ChildItem -LiteralPath $rootPath -Recurse -Force -File |
    Where-Object { $interesting -contains $_.Extension.ToLowerInvariant() -or $_.Name -match '(^|\.)(fstab|file_contexts|property_contexts|service_contexts)$' } |
    ForEach-Object { $_.FullName.Substring($rootPath.Length).TrimStart('\') } |
    Sort-Object |
    Set-Content -Encoding UTF8 $textCandidates

Write-Host "Created: $inventory"
Write-Host "Created: $textCandidates"
Write-Host 'Review/redact outputs before committing. Raw logs may contain identifiers, contacts, phone numbers, IP addresses or other private data.'
