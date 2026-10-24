@echo off
setlocal
title NOX Pocket AI - Local Chat
cd /d "%~dp0"
echo Starting the NOX Pocket AI local chat...
echo The server runs on THIS Windows PC, not in the cloud.
echo.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\start.ps1"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo.
  echo [ERROR] Unable to start the local chat.
  echo See TECH-SHEET.md for troubleshooting.
  pause
)
exit /b %CODE%
