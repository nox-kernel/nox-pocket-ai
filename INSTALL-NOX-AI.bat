@echo off
setlocal
title NOX Pocket AI - Install
cd /d "%~dp0"
echo ====================================================
echo  NOX POCKET AI - FIRST-TIME ONLINE SETUP
echo ====================================================
echo This downloads llama.cpp and the Qwen GGUF model to
echo the same folder as this file. No cloud API is used.
echo.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\install.ps1"
set "CODE=%ERRORLEVEL%"
echo.
if not "%CODE%"=="0" (
  echo [ERROR] Installer did not finish successfully. Review the error above.
) else (
  echo [OK] Installation finished. Next run VERIFY-NOX-AI.bat.
)
pause
exit /b %CODE%
