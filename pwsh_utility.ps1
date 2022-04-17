# source this file in your pwsh profile

#Requires -Version 6

# use `imagemagick` package as the converter
# you can obtain it via `Scoop` package manager or MSYS2(with `pacman -S mingw-w64-x86_64-imagemagick`)
# for more details, go to its official website (https://imagemagick.org/)
$ico_converter = "D:\Scoop\apps\imagemagick\current\magick.exe convert"

<# 
   Or you can also use toolchains from WSL (which allows you to use native linux tools),
   but you have to modify the script to handle the difference in path style between win & WSL 
   ans pass your commands via `wsl -e`
#>

# TODO: add doc
function png2ico {
    [CmdletBinding()]
    param (
        [alias("i")]
        [string] $input_file = $null,
        [alias("o")]
        [string] $output_file = $(
            if ($input_file) {
                "$(Split-Path -Path $input_file -Parent)/$(Split-Path -Path $input_file -LeafBase).ico"
            } else {
                $null
            }
        )
    )
    # TODO: handle pipe
    if (!$input_file) {
        return "You must specify a PNG file to be converted."
    }

    # convert relative path into absolute path
    if (!(Split-Path -Path $input_file -IsAbsolute)) {
        $input_file = [System.IO.Path]::GetFullPath($input_file, $pwd)
    }
    if (!(Split-Path -Path $output_file -IsAbsolute)) {
        $output_file = [System.IO.Path]::GetFullPath($output_file, $pwd)
    }

    # write-host "$ico_converter ""$input_file"" -define icon:auto-resize=256,64,48,32,16 ""$output_file""" # debug
    Invoke-Expression "$ico_converter ""$input_file"" -define icon:auto-resize=256,64,48,32,16 ""$output_file"""
}

function time {
    if (-not $args.Length) {
        Write-Host -ForegroundColor Magenta ('Usage: time [command [arg0 arg1 ...]]');
        return;
    }
    $command_str = ($args -join ' ') # to surpass the overhead of passing array in `iex @args`
    $start = Get-Date;
    Invoke-Expression $command_str;
    $end = Get-Date;
    Write-Host -ForegroundColor Magenta ('Total Runtime: ' + ($end - $start).TotalSeconds);
}

function gb {
    for ($_dir = "$pwd"; $_dir -and -not $(Test-Path "$_dir/.git/HEAD"); $_dir = Split-Path $_dir) {  }
    if ($_dir) {
        git status
    }
}

# Implementation of `systool`

$systool_cmdList = [ordered] @{
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
            param([hashtable] $enable_objs = $systool_cmdList.enable[0])
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
            param([hashtable] $disable_objs = $systool_cmdList.disable[0])
            if ($disable_objs.ContainsKey($stuff)) {
                &$disable_objs.$stuff
            } else {
                Write-Output "Can't disable unsupported object: ``$stuff``"
            }
        }
    )
    "set_rdp" = @(
        @{
            "<port>" = $null
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
    "locale"  = @(
        @{
            "utf-8" = {
                [System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(65001)
            }
            "gbk"   = {
                [System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(936)
            }
        },
        {
            param([hashtable] $locale_objs = $systool_cmdList.locale[0])
            if ($locale_objs.ContainsKey($stuff)) {
                &$locale_objs.$stuff
            } else {
                Write-Output "Can't change to unsupported locale: ``$stuff``"
            }
        }
    )
    "notepad" = @(
        @{
            "restore" = $null
            "<myExe>" = $null
        },
        {
            if ($stuff -match "restore") {
                sudo Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"`
                    -Name Debugger
            } else {
                $my_notepad = $(if ([String]::IsNullOrEmpty($stuff)) {
                        """D:\Scoop\apps\notepad3\current\Notepad3.exe"" /z"
                    } else {
                        $stuff
                    })
                $notepad_reg_entry = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"
                if ([String]::IsNullOrEmpty(($notepad_reg_entry | Get-Member | Select-String Debugger))) {
                    sudo New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"`
                        -Name Debugger -Value $my_notepad
                } else {
                    sudo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"`
                        -Name Debugger -Value $my_notepad
                    [Console]::Write("Debugger is set to ")
                    [Console]::ForegroundColor = [ConsoleColor]::Blue
                    Write-Output $my_notepad
                    [Console]::ResetColor();
                }
            }
        }
    )
}

function systool (
    [string] $subCommand,
    [string] $stuff,
    [alias("h")]
    [switch] $help
) {
    if ($help -or !$subCommand) {
        Write-Output "Available subcommands: `n======================="
        foreach ($key in $systool_cmdList.Keys) {
            Write-Output "$key`t[$($systool_cmdList.$key[0].Keys[0] -join ', ')]"
        }
        return
    }
    
    if ($systool_cmdList.Contains($subCommand)) {
        &$systool_cmdList.$subCommand[1]
    } else {
        Write-Output "Invalid subcommand: ``$subCommand``"
    }
}