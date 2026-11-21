$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$trackedFiles = @(git -C $repoRoot ls-files --cached)
if ($LASTEXITCODE -ne 0) {
    throw "Git could not enumerate the documentation files."
}

$documents = $trackedFiles |
    Where-Object { $_ -match '\.(md|pdf)$' } |
    Where-Object { Test-Path -LiteralPath (Join-Path $repoRoot $_) -PathType Leaf } |
    Sort-Object |
    ForEach-Object { $_ -replace '\\', '/' }

$manifest = @{
    documents   = @($documents)
}

$json = ($manifest | ConvertTo-Json -Depth 3) -replace "`r`n", "`n"
[System.IO.File]::WriteAllText(
    (Join-Path $repoRoot "docs-manifest.json"),
    $json + "`n",
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Wrote docs-manifest.json with $($documents.Count) documentation files."
