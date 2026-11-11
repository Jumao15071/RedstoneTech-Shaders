# Shrink a *.material.bin by re-optimising its ESSL shaders.
#
# Pipeline (based on the press/ folder):
#   1. lazurite unpack
#   2. per .glsl: glslangValidator -> SPIR-V -> spirv-opt -Os -> spirv-cross (310es)
#   3. tools\press-clean.py: drop layout(...), force highp, minify
#   4. lazurite pack back over the original file
#
# Only the ESSL_310 shader text is rewritten; DXBC/Metal blobs are carried over as-is.
param(
    [Parameter(Mandatory = $true)][string]$Bin,
    [string]$RepoRoot = "",
    [switch]$KeepTemp
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path $PSScriptRoot -Parent }

$press = Join-Path $RepoRoot 'press'
$glslang = Join-Path $press 'glslangValidator.exe'
$spirvOpt = Join-Path $press 'spirv-opt.exe'
$spirvCross = Join-Path $press 'spirv-cross.exe'
$cleaner = Join-Path $RepoRoot 'tools\press-clean.py'
$lazurite = Join-Path $RepoRoot 'tools\lazurite-0.12.0'

foreach ($exe in @($glslang, $spirvOpt, $spirvCross)) {
    if (-not (Test-Path $exe)) { Write-Error "missing tool: $exe"; exit 1 }
}
if (-not (Test-Path $lazurite)) { Write-Error "missing lazurite: $lazurite"; exit 1 }

$py = 'py'
if (-not (Get-Command py -ErrorAction SilentlyContinue)) { $py = 'python' }
$env:PYTHONPATH = $lazurite + ';' + $env:PYTHONPATH

if (-not (Test-Path $Bin)) { Write-Error "bin not found: $Bin"; exit 1 }
$binPath = (Resolve-Path $Bin).Path
$origSize = (Get-Item $binPath).Length
$name = [System.IO.Path]::GetFileNameWithoutExtension($binPath)

$work = Join-Path $RepoRoot ('build\press\' + $name + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $work | Out-Null

try {
    & $py -m lazurite unpack $binPath -o (Join-Path $work 'src') | Out-Null
    $matDir = Get-ChildItem -Directory (Join-Path $work 'src') | Select-Object -First 1
    if (-not $matDir) { Write-Error "unpack produced no material folder"; exit 1 }

    $glslFiles = Get-ChildItem -Recurse -File $matDir.FullName -Filter '*.glsl'
    if (-not $glslFiles) { Write-Error "no .glsl found in $($matDir.FullName)"; exit 1 }

    $tmpSpirv = Join-Path $work 'tmp.spirv'
    $tmpGlsl = Join-Path $work 'tmp.glsl'
    $failed = 0

    foreach ($f in $glslFiles) {
        $stage = if ($f.Name -match '\.Vertex\.') { 'vert' } elseif ($f.Name -match '\.Compute\.') { 'comp' } else { 'frag' }

        & $glslang $f.FullName --aml -G -Od -S $stage -o $tmpSpirv 2>$null | Out-Null
        if (-not (Test-Path $tmpSpirv)) { $failed++; continue }

        & $spirvOpt $tmpSpirv -Os -o $tmpSpirv 2>$null | Out-Null
        & $spirvCross $tmpSpirv --version 310es --output $tmpGlsl 2>$null | Out-Null
        if (-not (Test-Path $tmpGlsl)) { $failed++; Remove-Item $tmpSpirv -Force -ErrorAction SilentlyContinue; continue }

        Copy-Item $tmpGlsl $f.FullName -Force
        Remove-Item $tmpSpirv, $tmpGlsl -Force -ErrorAction SilentlyContinue
    }

    & $py $cleaner $matDir.FullName | Out-Null

    $outDir = Join-Path $work 'out'
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    & $py -m lazurite pack $matDir.FullName -o $outDir | Out-Null

    $packed = Join-Path $outDir ($matDir.Name + '.material.bin')
    if (-not (Test-Path $packed)) { Write-Error "repack produced no bin"; exit 1 }

    Copy-Item $packed $binPath -Force
    $newSize = (Get-Item $binPath).Length
    $ratio = if ($origSize) { [math]::Round(100.0 * $newSize / $origSize, 1) } else { 0 }
    Write-Host ("press: {0}  {1:N0} B -> {2:N0} B ({3}%), {4} shaders, {5} failed" -f `
        $name, $origSize, $newSize, $ratio, $glslFiles.Count, $failed)

    if ($failed) { Write-Host "press: some shaders were left untouched" }
    exit 0
}
finally {
    if (-not $KeepTemp) { Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue }
}
