param(
    [switch] $x # whether to close Xming
)

$VMRUN = "D:\\VMWare\vmrun.exe"
&$VMRUN list | Select-String ".*.vmx" | foreach-object { &$VMRUN -T ws suspend $_ }

if ($x) {
    try {
        $XMING = Get-Process "Xming" -ErrorAction Stop
    } catch {
        Write-Output "Xming isn't running."
    }
}

if ($XMING) {
    Stop-Process -Name "Xming"
}