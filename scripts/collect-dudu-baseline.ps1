param(
    [string]$Root = 'D:\carlinkit\DUDU_stock_opt\2608121631_2608120956',
    [string]$OutDir = '.\evidence\x21-sc162\stock'
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$rootPath = (Resolve-Path $Root).Path

function Write-Inventory($InputPath, $OutputName) {
    $out = Join-Path $OutDir $OutputName
    "relative_path\tsize\tlast_write_utc\textension" | Set-Content -Encoding UTF8 $out
    if (Test-Path $InputPath) {
        Get-ChildItem -LiteralPath $InputPath -Recurse -Force -File | ForEach-Object {
            $rel = $_.FullName.Substring($rootPath.Length).TrimStart('\') -replace "`t", ' '
            "$rel`t$($_.Length)`t$($_.LastWriteTimeUtc.ToString('o'))`t$($_.Extension)" | Add-Content -Encoding UTF8 $out
        }
    }
}

Write-Inventory (Join-Path $rootPath '03_images') 'image-files.tsv'
Write-Inventory (Join-Path $rootPath '04_files\new') 'analysis-files.tsv'
Write-Inventory (Join-Path $rootPath '06_live_logs') 'live-log-files.tsv'

$hashOut = Join-Path $OutDir 'image-sha256.tsv'
"relative_path\tsha256\tsize" | Set-Content -Encoding UTF8 $hashOut
$imageRoot = Join-Path $rootPath '03_images'
if (Test-Path $imageRoot) {
    Get-ChildItem -LiteralPath $imageRoot -File | ForEach-Object {
        $h = Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
        $rel = $_.FullName.Substring($rootPath.Length).TrimStart('\')
        "$rel`t$($h.Hash.ToLowerInvariant())`t$($_.Length)" | Add-Content -Encoding UTF8 $hashOut
    }
}

Write-Host "Created DUDU baseline inventories in $OutDir"
Write-Host 'The analysis-files tree is not authoritative for Linux metadata; use original images/live evidence for permissions, labels, symlinks, xattrs and capabilities.'
