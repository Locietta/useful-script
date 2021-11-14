param (
    [string] $subCommand,
    [string] $stuff,
    [alias("h")]
    [switch] $help
)

$commandList = @{
    "enable"  = @(
        @{
            "admin"  = {
                sudo net user administrator /active:yes
            }
            "hyperv" = {
                sudo bcdedit /set hypervisorlaunchtype auto
            }
        }, 
        {
            param([hashtable] $enable_objs = $commandList.enable[0])
            if ($enable_objs.ContainsKey($stuff)) {
                &$enable_objs.$stuff
            } else {
                Write-Output "Can't enable unsupported object: ``$stuff``"
            }
        }
    )
    "disable" = @(
        @{
            "admin"  = {
                sudo net user administrator /active:no
            }
            "hyperv" = {
                sudo bcdedit /set hypervisorlaunchtype off
            }
        },
        {
            param([hashtable] $disable_objs = $commandList.disable[0])
            if ($disable_objs.ContainsKey($stuff)) {
                &$disable_objs.$stuff
            } else {
                Write-Output "Can't disable unsupported object: ``$stuff``"
            }
        }
    )
}

if ($help -or !$subCommand) {
    Write-Output "Available subcommands: `n======================="
    foreach ($key in $commandList.Keys) {
        Write-Output "$key`t[$($commandList.$key[0].Keys[0] -join ', ')]"
    }
    exit
}

if ($commandList.ContainsKey($subCommand)) {
    &$commandList.$subCommand[1]
} else {
    Write-Output "Invalid subcommand: ``$subCommand``"
}