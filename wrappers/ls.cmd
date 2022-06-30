@echo off
for /f "tokens=1,* delims= " %%a in ("%*") do set ALL_BUT_1=%%b
if "%1"=="" goto noarg
wsl -d Ubuntu -- ls --color=tty $(wslpath %1) %ALL_BUT_1%
goto :eof
:noarg
wsl -d Ubuntu -- ls --color=tty