@echo off

@REM Using MSYS2's ls.exe is better than the WSL's
@REM However, it doesn't handle well about the NTFS's hidden properties
@REM eza is a better modern alternative, it's real native without Cygwin tweaks and works well with NTFS
@REM 
@REM eza is mostly compatible with GNU ls, and having better defaults
@REM I tried to use eza as a drop-in replacement for ls, from what I can see, it works well
@REM So I decided to deprecate this wrapper

%MSYS2%\usr\bin\ls.exe --color %*