@REM simple warpper for WSL1 distro as WSL2 is my default distro
@REM easy to invoke WSL1 command line interops, workaround WSL2 performance issue over interop

@echo off

wsl -d Ubuntu -- %*