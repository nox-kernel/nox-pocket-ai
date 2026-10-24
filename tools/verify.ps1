# NOX Pocket AI - fully offline local file checks (not a substitute for live inference)
$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$exe = Join-Path $root 'bin\llama-server.exe'
$model = Join-Path $root 'models\Qwen3-1.7B-Q4_K_M.gguf'
$manifestPath = Join-Path $PSScriptRoot 'download-manifest.json'
$failures = 0

function Pass([string]$message) { Write-Host ('[PASS] ' + $message) -ForegroundColor Green }
function Fail([string]$message) { Write-Host ('[FAIL] ' + $message) -ForegroundColor Red; $script:failures += 1 }
function Note([string]$message) { Write-Host ('[INFO] ' + $message) -ForegroundColor Cyan }

try {
    Note ('Project path: ' + $root)
    if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem -or [IntPtr]::Size -ne 8) {
        Fail 'This kit requires Windows x64.'
    } else {
        Pass 'Windows x64 runtime environment.'
    }
    try {
        $ramBytes = [long](Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
        $ramGiB = [math]::Round(($ramBytes / 1GB), 1)
        Note ("Host RAM: $ramGiB GiB (8 GiB+ recommended)")
    } catch {
        Note 'Could not query host RAM.'
    }

    if (-not (Test-Path -LiteralPath $exe)) {
        Fail 'llama-server.exe missing. Run INSTALL-NOX-AI.bat while online.'
    } elseif ((Get-Item -LiteralPath $exe).Length -lt 100KB) {
        Fail 'llama-server.exe looks unexpectedly small.'
    } else {
        Pass 'llama-server.exe is present.'
    }

    if (-not (Test-Path -LiteralPath $model)) {
        Fail 'Qwen3 GGUF missing. Run INSTALL-NOX-AI.bat while online.'
    } elseif ((Get-Item -LiteralPath $model).Length -lt 300MB) {
        Fail 'Model file is implausibly small/incomplete.'
    } else {
        $stream = [System.IO.File]::OpenRead($model)
        try {
            $buffer = New-Object byte[] 4
            [void]$stream.Read($buffer, 0, 4)
            if ([System.Text.Encoding]::ASCII.GetString($buffer) -ne 'GGUF') {
                Fail 'Model header is not GGUF.'
            } else {
                Pass ('GGUF model present (' + [math]::Round(((Get-Item $model).Length / 1GB), 2) + ' GiB).')
            }
        } finally {
            $stream.Dispose()
        }
    }

    if (Test-Path -LiteralPath $manifestPath) {
        try {
            $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
            Note ('Installed runtime version: ' + [string]$manifest.runtime_tag)
            if (Test-Path -LiteralPath $model) {
                $currentHash = (Get-FileHash -LiteralPath $model -Algorithm SHA256).Hash.ToLowerInvariant()
                if ($currentHash -eq [string]$manifest.model_sha256) {
                    Pass 'Local GGUF SHA-256 matches the install manifest.'
                } else {
                    Fail 'GGUF SHA-256 does not match the install manifest; re-download before using.'
                }
            }
            if (-not [bool]$manifest.model_publisher_digest_verified) {
                Note 'The install manifest does not record a publisher-verified GGUF digest; local integrity only.'
            }
        } catch {
            Fail ('Could not read manifest / verify hash: ' + $_.Exception.Message)
        }
    } else {
        Note 'No download-manifest.json yet; reinstall online to create a local verification record.'
    }

    Write-Host ''
    if ($failures -gt 0) {
        Write-Host ("Verification found $failures problem(s).") -ForegroundColor Red
        exit 1
    }
    Pass 'Local file checks completed. Now do a real chat + offline network test.'
    exit 0
} catch {
    Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
