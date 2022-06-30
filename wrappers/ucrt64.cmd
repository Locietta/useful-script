@echo off
if "%1"=="" goto noarg
D:/msys64/msys2_shell.cmd -defterm -no-start -here -ucrt64 -c %*
goto :eof
:noarg
D:/msys64/msys2_shell.cmd -defterm -no-start -here -ucrt64