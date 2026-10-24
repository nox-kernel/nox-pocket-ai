# NOX Pocket AI - offline local server launcher
$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$exe = Join-Path $root 'bin\llama-server.exe'
$model = Join-Path $root 'models\Qwen3-1.7B-Q4_K_M.gguf'
$url = 'http://127.0.0.1:8080'
$health = $url + '/health'

function Test-LocalPort {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $pending = $client.BeginConnect('127.0.0.1', 8080, $null, $null)
        if (-not $pending.AsyncWaitHandle.WaitOne(400)) { return $false }
        $client.EndConnect($pending)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

try {
    if ($env:OS -ne 'Windows_NT') { throw 'Requires Windows.' }
    if (-not (Test-Path -LiteralPath $exe)) { throw 'Missing bin\llama-server.exe. Run INSTALL-NOX-AI.bat while online first.' }
    if (-not (Test-Path -LiteralPath $model)) { throw 'Missing model GGUF. Run INSTALL-NOX-AI.bat while online first.' }
    if (Test-LocalPort) { throw 'Port 8080 is already in use. Close the other server/application before launching NOX.' }

    # Windows CreateProcess needs a single quoted argument string for a path containing spaces.
    $arguments = '-m "' + $model + '" --host 127.0.0.1 --port 8080 --ctx-size 2048 --n-gpu-layers 0'
    Write-Host 'Starting local llama.cpp server on this computer (CPU only)...' -ForegroundColor Cyan
    Write-Host ('Model: ' + $model)
    $process = Start-Process -FilePath $exe -ArgumentList $arguments -WorkingDirectory (Split-Path $exe -Parent) -PassThru
    Write-Host ('Server process PID: ' + $process.Id)
    Write-Host 'A separate server window should remain open while you chat.'
    Write-Host 'Waiting for model loading and http://127.0.0.1:8080/health ...'

    $ready = $false
    for ($attempt = 0; $attempt -lt 120; $attempt++) {
        $process.Refresh()
        if ($process.HasExited) { throw ('Server exited early with code ' + $process.ExitCode + '. Check the server console for details.') }
        try {
            $request = [System.Net.HttpWebRequest]::Create($health)
            $request.Method = 'GET'
            $request.Timeout = 1000
            $response = $request.GetResponse()
            try {
                if ([int]$response.StatusCode -eq 200) { $ready = $true; break }
            } finally {
                $response.Close()
            }
        } catch { }
        Start-Sleep -Seconds 1
    }
    if (-not $ready) {
        Write-Warning 'Server has not reported ready after about two minutes. Check its console and try OPEN-LOCAL-CHAT.url once it has loaded.'
        exit 1
    }
    Write-Host '[OK] Local AI ready. Opening the built-in browser chat...' -ForegroundColor Green
    Start-Process $url | Out-Null
    Write-Host 'To stop it, close the llama.cpp server window (or press Ctrl+C there) before ejecting the USB.'
    exit 0
} catch {
    Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
