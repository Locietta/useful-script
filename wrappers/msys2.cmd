@echo off
if "%1"=="" goto noarg
%MSYS2%\msys2_shell.cmd -defterm -no-start -here -msys2 -c "%*"
goto :eof
:noarg
%MSYS2%\msys2_shell.cmd -defterm -no-start -here -msys2