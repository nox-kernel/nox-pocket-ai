# Offline, read-only checks against the pinned runtime and model.
[CmdletBinding()]
param([string]$Root = '')
$ErrorActionPreference = 'Stop'
if (-not $Root) { $Root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')) }
$assets = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'asset-manifest.json') -Raw | ConvertFrom-Json
$failures = 0
function Pass([string]$message) { Write-Host ('[PASS] ' + $message) -ForegroundColor Green }
function Fail([string]$message) { Write-Host ('[FAIL] ' + $message) -ForegroundColor Red; $script:failures += 1 }
function Note([string]$message) { Write-Host ('[INFO] ' + $message) -ForegroundColor Cyan }

try {
    $Root = [IO.Path]::GetFullPath($Root)
    Note ('Project path: ' + $Root)
    if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem -or [IntPtr]::Size -ne 8 -or $env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        Fail 'This kit requires Windows x64.'
    } else { Pass 'Windows x64 runtime environment.' }

    Note ('Checking llama.cpp ' + $assets.runtime.tag + ' runtime files and DLLs...')
    $runtimeFailures = $failures
    foreach ($file in $assets.runtime.files.PSObject.Properties) {
        $path = Join-Path (Join-Path $Root 'bin') $file.Name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            Fail ('Missing runtime file: ' + $file.Name)
        } elseif ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.Value) {
            Fail ('Runtime SHA-256 mismatch: ' + $file.Name)
        }
    }
    # b11809 has a small EXE plus implementation DLLs; EXE size alone is not a validity check.
    if ($failures -eq $runtimeFailures) { Pass 'All pinned runtime files match, including the server EXE and its DLLs.' }

    $model = Join-Path (Join-Path $Root 'models') $assets.model.filename
    if (-not (Test-Path -LiteralPath $model -PathType Leaf)) {
        Fail 'GGUF model missing. Run INSTALL-NOX-AI.bat while online.'
    } elseif ((Get-Item -LiteralPath $model).Length -ne [long]$assets.model.size_bytes) {
        Fail 'Model size does not match the pinned GGUF.'
    } else {
        Note 'Reading the 1.28 GB model for its SHA-256 check; this can take a moment...'
        if ((Get-FileHash -LiteralPath $model -Algorithm SHA256).Hash.ToLowerInvariant() -eq $assets.model.sha256) {
            Pass 'GGUF SHA-256 matches the pinned publisher value.'
        } else { Fail 'GGUF SHA-256 mismatch. Keep this folder as a backup and install a fresh copy.' }
    }
    Write-Host ''
    if ($failures -gt 0) {
        Write-Host ("Verification found $failures problem(s). See TECH-SHEET.md.") -ForegroundColor Red
        exit 1
    }
    Pass 'Local file checks completed. Start the chat next; offline operation needs a separate real test.'
    exit 0
} catch {
    Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
