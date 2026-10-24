@echo off
setlocal
title NOX Pocket AI - Verify
cd /d "%~dp0"
echo Checking your local NOX Pocket AI USB files...
echo.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\verify.ps1"
set "CODE=%ERRORLEVEL%"
echo.
if not "%CODE%"=="0" (
  echo [FAIL] At least one verification check failed.
) else (
  echo [OK] Files verified. Run START-NOX-AI.bat to test the server.
)
pause
exit /b %CODE%
