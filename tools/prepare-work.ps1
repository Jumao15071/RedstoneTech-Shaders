# Mirror the shader project into build\work and point its merge_source at the
# vanilla material library, so the source tree is never modified by a build.
param(
    [Parameter(Mandatory = $true)][string]$Src,
    [Parameter(Mandatory = $true)][string]$Work,
    [Parameter(Mandatory = $true)][string]$Vanilla
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path (Join-Path $Src 'project.json'))) {
    Write-Error "project.json not found under '$Src'"
    exit 1
}
if (-not (Test-Path (Join-Path $Vanilla 'RenderChunk.material.bin'))) {
    Write-Error "vanilla material library not found: '$Vanilla'"
    exit 1
}

New-Item -ItemType Directory -Force -Path $Work | Out-Null
robocopy $Src $Work /MIR /NFL /NDL /NJH /NJS /NP /R:2 /W:2 | Out-Null
if ($LASTEXITCODE -ge 8) {
    Write-Error "robocopy failed with exit code $LASTEXITCODE"
    exit 1
}

# Rewrite merge_source to an absolute path (keeps the checked-in project.json portable).
$projectJson = Join-Path $Work 'project.json'
$raw = [System.IO.File]::ReadAllText($projectJson)
$escaped = $Vanilla.Replace('\', '\\')
$updated = [regex]::Replace(
    $raw,
    '(?<="merge_source"\s*:\s*\[)[^\]]*(?=\])',
    { param($m) '"' + $escaped + '"' }
)
if ($updated -eq $raw -and $raw -notmatch '"merge_source"') {
    Write-Error "merge_source not found in '$projectJson'"
    exit 1
}
[System.IO.File]::WriteAllText($projectJson, $updated, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "work tree: $Work"
Write-Host "merge_source: $Vanilla"
exit 0
