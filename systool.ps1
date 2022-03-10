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
    "set_rdp" = @(
        @{
            "port" = $null
        },
        {
            if ($stuff -match "^([1-9]\d*|0)$") {
                Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" -Value $stuff 
                New-NetFirewallRule -DisplayName 'RDPPORTLatest-TCP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $stuff 
                New-NetFirewallRule -DisplayName 'RDPPORTLatest-UDP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort $stuff
            } else {
                Write-Output "Not a valid port number: ``$stuff``"
            }
        }
    )
    "locale" = @(
        @{
            "utf-8" = {
                [System.Console]::OutputEncoding=[System.Text.Encoding]::GetEncoding(65001)
            }
            "gbk" = {
                [System.Console]::OutputEncoding=[System.Text.Encoding]::GetEncoding(936)
            }
        },
        {
            param([hashtable] $locale_objs = $commandList.locale[0])
            if ($locale_objs.ContainsKey($stuff)) {
                &$locale_objs.$stuff
            } else {
                Write-Output "Can't change to unsupported locale: ``$stuff``"
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