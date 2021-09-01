$VMRUN = "D:\\VMWare\vmrun.exe"
$XMING = "D:\\Scoop\\apps\\xming\\current\\Xming.exe"
$Machine = "D:\\.WSL\\ArchLinuxVMWare\\ArchLinux.vmx"

try { # start X server if not started
    $SILENT = Get-Process "Xming" -ErrorAction Stop # to make it silent
} catch { 
    Invoke-Expression "$XMING :0 -clipboard -multiwindow";
} 

$FIND_MACHINE = &$VMRUN list | Select-String $Machine
if (-not $FIND_MACHINE) { # start VM if not started
    &$VMRUN -T ws start $Machine nogui;
}

ssh.exe -Y loia@192.168.159.128;