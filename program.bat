@echo off
(
echo setMode -bs
echo setCable -port auto
echo Identify -inferir
echo identifyMPM
echo assignFile -p 1 -file %1
echo Program -p 1
) > D:\.config\Vivado-shortcut\temp_cmd.cmd

D:\Xilinx\14.6\LabTools\LabTools\bin\nt\impact.exe -batch D:\.config\Vivado-shortcut\cache\temp_cmd.cmd

@REM del D:\.config\Vivado-shortcut\cache\temp_cmd.cmd

del %cd%\_impactbatch.log