@echo off
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0claudex.ps1" %*
exit /b %ERRORLEVEL%
