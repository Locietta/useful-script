@REM This wrapper calls `ls` cmd in wsl1

@REM The problem of this wrapper is that pipe between wsl 
@REM and windows can somehow lose data (probably a bug...)
@REM This causes `ls | grep xxx` gives incorrect result
@REM 
@REM Use ls.exe shipped by msys2/cygwin is better

@echo off
for /f "tokens=1,* delims= " %%a in ("%*") do set ALL_BUT_1=%%b
if "%1"=="" goto noarg
wsl -d Ubuntu -- ls --color=tty $(wslpath '%1') %ALL_BUT_1%
goto :eof
:noarg
wsl -d Ubuntu -- ls --color=tty