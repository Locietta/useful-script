$VMRUN = "D:\\VMWare\vmrun.exe"
$X_SRV = "D:\\Scoop\\apps\\vcxsrv\\current\\vcxsrv.exe"
# $X_SRV = "C:\\Users\pc\AppData\Local\Microsoft\WindowsApps\x410.exe"
$Machine = "D:\\.WSL\\ArchLinuxVMWare\\ArchLinux.vmx"

$env:DISPLAY = "localhost:0.0" # set X recieve port

try { # start X server if not started
    # $SILENT = Get-Process "x410" -ErrorAction Stop; # to make it silent
    $SILENT = Get-Process "vcxsrv" -ErrorAction Stop; 
} catch { # start X server before vm, or X Forwarding will fail
    # &$X_SRV ":0" /wm /public;
    &$X_SRV ":0" -clipboard -multiwindow -ac -wgl;
} 

$FIND_MACHINE = &$VMRUN list | Select-String $Machine
if (-not $FIND_MACHINE) { # start VM if not started
    &$VMRUN -T ws start $Machine nogui;
}

ssh.exe -Y loia@192.168.159.129;