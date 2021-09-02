param(
    [switch] $x # whether to close X Server
)

$VMRUN = "D:\\VMWare\vmrun.exe"
&$VMRUN list | Select-String ".*.vmx" | foreach-object { &$VMRUN -T ws suspend $_ }

if ($x) {
    try {
        $X_SRV = Get-Process "vcxsrv" -ErrorAction Stop
    } catch {
        Write-Output "X Server isn't running."
    }
}

if ($X_SRV) {
    Stop-Process -Name "vcxsrv"
}