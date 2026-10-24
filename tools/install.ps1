# NOX Pocket AI - idempotent Windows x64 online installer
# Downloads published llama.cpp CPU binaries and Qwen3 GGUF, keeping them on this USB.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$bin = Join-Path $root 'bin'
$models = Join-Path $root 'models'
$temp = Join-Path $PSScriptRoot '.tmp'
$manifestPath = Join-Path $PSScriptRoot 'download-manifest.json'
$modelName = 'Qwen3-1.7B-Q4_K_M.gguf'
$modelPath = Join-Path $models $modelName
$serverPath = Join-Path $bin 'llama-server.exe'
$modelUrl = 'https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q4_K_M.gguf'
$modelApi = 'https://huggingface.co/api/models/unsloth/Qwen3-1.7B-GGUF/tree/main'
$releaseApi = 'https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=100'
$headers = @{ 'User-Agent' = 'NOX-Pocket-AI-Installer'; 'Accept' = 'application/vnd.github+json' }

function Write-Step([string]$message) {
    Write-Host ("[NOX] " + $message) -ForegroundColor Cyan
}
function Sha256([string]$path) {
    return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Download-File([string]$url, [string]$destination) {
    $part = $destination + '.part'
    if (Test-Path -LiteralPath $part) { Remove-Item -LiteralPath $part -Force }
    Write-Step ("Downloading: " + $url)
    Invoke-WebRequest -Uri $url -OutFile $part -UseBasicParsing -MaximumRedirection 10 -TimeoutSec 1800
    if (-not (Test-Path -LiteralPath $part) -or (Get-Item -LiteralPath $part).Length -le 0) {
        throw "Download was empty: $url"
    }
    Move-Item -LiteralPath $part -Destination $destination -Force
}
function Test-Gguf([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    if ((Get-Item -LiteralPath $path).Length -lt 300MB) { return $false }
    $stream = [System.IO.File]::OpenRead($path)
    try {
        $magic = New-Object byte[] 4
        if ($stream.Read($magic, 0, 4) -ne 4) { return $false }
        return ([System.Text.Encoding]::ASCII.GetString($magic) -eq 'GGUF')
    } finally {
        $stream.Dispose()
    }
}

try {
    if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem -or [IntPtr]::Size -ne 8) {
        throw 'This starter requires 64-bit Windows on x64 hardware.'
    }
    # TLS 1.2 for older Windows PowerShell 5.1 defaults.
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
    foreach ($directory in @($bin, $models, $temp)) {
        if (-not (Test-Path -LiteralPath $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
    }
    Write-Step ("Project folder: " + $root)
    Write-Step 'Source: official ggml-org/llama.cpp releases and Unsloth Qwen3 GGUF'

    $runtimeTag = 'pre-existing'
    $runtimeAssetName = 'pre-existing'
    $runtimeArchiveSha = ''
    $runtimeDigestVerified = $false

    if (-not (Test-Path -LiteralPath $serverPath)) {
        Write-Step 'Checking available llama.cpp Windows CPU builds...'
        $releases = @(Invoke-RestMethod -Uri $releaseApi -Headers $headers -TimeoutSec 90)
        $selection = $null
        foreach ($release in $releases) {
            if ($release.draft -or $release.prerelease) { continue }
            $asset = @($release.assets | Where-Object { $_.name -match '^llama-.*-bin-win-cpu-x64\.zip$' } | Select-Object -First 1)
            if ($asset.Count -gt 0) {
                $selection = @{ Release = $release; Asset = $asset[0] }
                break
            }
        }
        if (-not $selection) {
            throw 'No suitable Windows CPU x64 ZIP was found in recent llama.cpp releases. Check official releases and report a changed asset name.'
        }
        $runtimeTag = [string]$selection.Release.tag_name
        $runtimeAssetName = [string]$selection.Asset.name
        $zip = Join-Path $temp 'llama-win-cpu.zip'
        $unpacked = Join-Path $temp 'unpacked'
        if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
        if (Test-Path -LiteralPath $unpacked) { Remove-Item -LiteralPath $unpacked -Recurse -Force }
        Write-Step ("Selected " + $runtimeTag + ' / ' + $runtimeAssetName)
        Download-File ([string]$selection.Asset.browser_download_url) $zip
        $runtimeArchiveSha = Sha256 $zip
        $publishedDigest = [string]$selection.Asset.digest
        if ($publishedDigest -match '^sha256:([0-9a-fA-F]{64})$') {
            if ($runtimeArchiveSha -ne $Matches[1].ToLowerInvariant()) { throw 'llama.cpp archive SHA-256 does not match the upstream digest.' }
            $runtimeDigestVerified = $true
            Write-Step 'llama.cpp archive SHA-256 matched the publisher digest.'
        } else {
            Write-Warning 'GitHub metadata has no SHA-256 for this archive; calculated a local hash, but publisher digest verification was not available.'
        }
        Expand-Archive -LiteralPath $zip -DestinationPath $unpacked -Force
        $serverFile = Get-ChildItem -LiteralPath $unpacked -File -Recurse -Filter 'llama-server.exe' |
            Sort-Object { $_.FullName.Length } | Select-Object -First 1
        if (-not $serverFile) { throw 'Downloaded ZIP does not contain llama-server.exe; the upstream packaging may have changed.' }
        # DLLs sit beside the server in the release's binary directory; copy the entire directory.
        Get-ChildItem -LiteralPath $serverFile.DirectoryName -Force |
            Copy-Item -Destination $bin -Recurse -Force
        if (-not (Test-Path -LiteralPath $serverPath)) { throw 'Failed to install llama-server.exe.' }
        Remove-Item -LiteralPath $zip -Force
        Remove-Item -LiteralPath $unpacked -Recurse -Force
        Write-Step 'Installed llama.cpp binaries and DLLs.'
    } else {
        Write-Step 'Existing llama-server.exe found; keeping this local runtime.'
    }

    Write-Step 'Checking Qwen3 GGUF publisher file metadata...'
    $modelMeta = $null
    try {
        $tree = @(Invoke-RestMethod -Uri $modelApi -TimeoutSec 90)
        $modelMeta = @($tree | Where-Object { $_.path -eq $modelName } | Select-Object -First 1)
        if ($modelMeta.Count -gt 0) { $modelMeta = $modelMeta[0] } else { $modelMeta = $null }
    } catch {
        Write-Warning 'Hugging Face metadata was unavailable. File size and GGUF header will still be checked, but publisher hash verification may not be available.'
    }
    $publishedModelHash = ''
    $publishedModelSize = [long]0
    if ($modelMeta) {
        $publishedModelSize = [long]$modelMeta.size
        if ($modelMeta.lfs) {
            $publishedModelHash = [string]$modelMeta.lfs.sha256
            if (-not $publishedModelHash) { $publishedModelHash = [string]$modelMeta.lfs.oid }
        }
        if ($publishedModelHash -notmatch '^[0-9a-fA-F]{64}$') { $publishedModelHash = '' }
    }

    if (-not (Test-Path -LiteralPath $modelPath)) {
        Write-Step 'Downloading Qwen3 1.7B Q4_K_M model (~1.1GB). This may take a while...'
        Download-File $modelUrl $modelPath
    } else {
        Write-Step 'Existing GGUF found; validating it without replacing it.'
    }
    if (-not (Test-Gguf $modelPath)) { throw 'Model is missing, too small or has an invalid GGUF header.' }
    $actualSize = (Get-Item -LiteralPath $modelPath).Length
    if ($publishedModelSize -gt 0 -and $actualSize -ne $publishedModelSize) {
        throw "Model size mismatch: got $actualSize bytes; publisher says $publishedModelSize bytes."
    }
    $modelSha = Sha256 $modelPath
    $modelDigestVerified = $false
    if ($publishedModelHash) {
        if ($modelSha -ne $publishedModelHash.ToLowerInvariant()) { throw 'Qwen GGUF SHA-256 does not match publisher metadata.' }
        $modelDigestVerified = $true
        Write-Step 'Qwen model SHA-256 matches publisher metadata.'
    } else {
        Write-Warning 'Publisher SHA-256 metadata unavailable. GGUF header/size checked; local hash recorded for future integrity checks.'
    }

    $old = $null
    if (Test-Path -LiteralPath $manifestPath) {
        try { $old = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json } catch { }
    }
    if ($runtimeTag -eq 'pre-existing' -and $old) {
        $runtimeTag = [string]$old.runtime_tag
        $runtimeAssetName = [string]$old.runtime_asset
        $runtimeArchiveSha = [string]$old.runtime_archive_sha256
        $runtimeDigestVerified = [bool]$old.runtime_digest_verified
    }
    $manifest = @{
        project = 'NOX Pocket AI'
        installed_utc = (Get-Date).ToUniversalTime().ToString('o')
        runtime_source = 'https://github.com/ggml-org/llama.cpp/releases'
        runtime_tag = $runtimeTag
        runtime_asset = $runtimeAssetName
        runtime_archive_sha256 = $runtimeArchiveSha
        runtime_digest_verified = $runtimeDigestVerified
        model_source = $modelUrl
        model_filename = $modelName
        model_size_bytes = $actualSize
        model_sha256 = $modelSha
        model_publisher_sha256 = $publishedModelHash
        model_publisher_digest_verified = $modelDigestVerified
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
    Write-Host ''
    Write-Host '[OK] Installed. Run VERIFY-NOX-AI.bat, then START-NOX-AI.bat.' -ForegroundColor Green
    Write-Host 'You can disconnect the internet before starting chat after this one-time setup.'
    exit 0
} catch {
    Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'See TECH-SHEET.md. Nothing has formatted or wiped your USB.'
    exit 1
}
