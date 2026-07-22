@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0claudex.ps1" %*
exit /b %ERRORLEVEL%
