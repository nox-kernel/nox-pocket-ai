# NOX Pocket AI - one-time Windows x64 online setup.
# Sources and mandatory SHA-256 values are pinned in asset-manifest.json.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$bin = Join-Path $root 'bin'
$models = Join-Path $root 'models'
$assets = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'asset-manifest.json') -Raw | ConvertFrom-Json
$work = Join-Path (Join-Path $PSScriptRoot '.tmp') ([guid]::NewGuid().ToString('N'))

function Step([string]$message) { Write-Host ('[NOX] ' + $message) -ForegroundColor Cyan }
function Hash([string]$path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Test-Asset([string]$path, $asset) {
    (Test-Path -LiteralPath $path -PathType Leaf) -and
    ((Get-Item -LiteralPath $path).Length -eq [long]$asset.size_bytes) -and
    ((Hash $path) -eq $asset.sha256)
}
function Get-Asset($asset, [string]$destination) {
    Step ('Downloading ' + $asset.filename)
    Write-Host ('  ' + $asset.url)
    $partial = $destination + '.part'
    $curl = Get-Command 'curl.exe' -ErrorAction SilentlyContinue
    if ($curl) {
        & $curl.Source --fail --location --retry 3 --connect-timeout 30 --output $partial $asset.url
        if ($LASTEXITCODE -ne 0) { throw ('Download failed for ' + $asset.filename) }
    } else {
        Invoke-WebRequest -Uri $asset.url -OutFile $partial -UseBasicParsing -MaximumRedirection 10 -TimeoutSec 1800
    }
    Step ('Checking size and SHA-256: ' + $asset.filename)
    if (-not (Test-Asset $partial $asset)) { throw ('Download failed its pinned size/SHA-256 check: ' + $asset.filename) }
    Move-Item -LiteralPath $partial -Destination $destination
    Write-Host '[OK] Download verified.' -ForegroundColor Green
}

try {
    if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem -or [IntPtr]::Size -ne 8 -or $env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        throw 'This starter requires 64-bit Windows on x64 hardware.'
    }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    foreach ($directory in @($bin, $models, $work)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
    Step ('Project folder: ' + $root)
    Step ('Pinned runtime: llama.cpp ' + $assets.runtime.tag + ' Windows x64 CPU')
    Write-Host 'The model is 1.28 GB. Leave this window open; downloads can take several minutes.'
    Write-Host 'Existing runtime/model files are checked and kept. This installer never formats a drive.'

    $runtimeFiles = @($assets.runtime.files.PSObject.Properties)
    $present = @($runtimeFiles | Where-Object { Test-Path -LiteralPath (Join-Path $bin $_.Name) })
    $runtimeVerified = $present.Count -eq $runtimeFiles.Count
    if ($runtimeVerified) {
        foreach ($file in $runtimeFiles) {
            if ((Hash (Join-Path $bin $file.Name)) -ne $file.Value) { $runtimeVerified = $false; break }
        }
    }
    if (-not $runtimeVerified -and $present.Count -gt 0) {
        throw 'Existing runtime files differ from the pinned build or are incomplete. Keep this folder as a backup and extract a fresh project folder; no existing runtime files were replaced.'
    }
    if ($runtimeVerified) {
        Step 'Existing runtime files match the pinned release; no runtime download needed.'
    } else {
        $zip = Join-Path $work $assets.runtime.filename
        Get-Asset $assets.runtime $zip
        $unpacked = Join-Path $work 'unpacked'
        Step 'Extracting runtime and companion DLLs...'
        Expand-Archive -LiteralPath $zip -DestinationPath $unpacked
        $server = Get-ChildItem -LiteralPath $unpacked -File -Recurse -Filter 'llama-server.exe' | Select-Object -First 1
        if (-not $server) { throw 'The verified archive did not contain llama-server.exe.' }
        foreach ($file in $runtimeFiles) {
            $source = Join-Path $server.DirectoryName $file.Name
            if (-not (Test-Path -LiteralPath $source -PathType Leaf) -or (Hash $source) -ne $file.Value) {
                throw ('Extracted runtime file did not match: ' + $file.Name)
            }
        }
        Get-ChildItem -LiteralPath $server.DirectoryName -Force | Copy-Item -Destination $bin -Recurse
        Step 'Runtime installed with all companion DLLs.'
    }

    $model = Join-Path $models $assets.model.filename
    if (Test-Path -LiteralPath $model) {
        Step 'Checking the existing model; it will not be replaced.'
        if (-not (Test-Asset $model $assets.model)) {
            throw 'Existing model differs from the pinned GGUF. Keep it as a backup and use a fresh project folder; no model was replaced.'
        }
    } else {
        $download = Join-Path $work $assets.model.filename
        Get-Asset $assets.model $download
        Move-Item -LiteralPath $download -Destination $model
    }
    $receipt = [ordered]@{
        project = 'NOX Pocket AI'
        installed_utc = (Get-Date).ToUniversalTime().ToString('o')
        runtime_tag = $assets.runtime.tag
        runtime_asset = $assets.runtime.filename
        runtime_archive_sha256 = $assets.runtime.sha256
        runtime_files_verified = $runtimeFiles.Count
        model_source = $assets.model.url
        model_filename = $assets.model.filename
        model_size_bytes = $assets.model.size_bytes
        model_sha256 = $assets.model.sha256
    }
    $receipt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'download-manifest.json') -Encoding UTF8
    Write-Host ''
    Write-Host '[OK] Installed. Double-click VERIFY-NOX-AI.bat, then START-NOX-AI.bat.' -ForegroundColor Green
    Write-Host 'Internet was needed for setup. An offline launch/chat test is a separate check.'
    exit 0
} catch {
    Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'See TECH-SHEET.md. No drive has been formatted.'
    exit 1
} finally {
    # Remove only this invocation's newly created staging directory, within its exact boundary.
    $tempRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '.tmp')).TrimEnd('\') + '\'
    $resolvedWork = [IO.Path]::GetFullPath($work)
    if ($resolvedWork.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedWork)) {
        Remove-Item -LiteralPath $resolvedWork -Recurse -Force -ErrorAction SilentlyContinue
    }
}
