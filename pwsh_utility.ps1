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
        Write-Host -ForegroundColor Magenta ('Usage: time [command [arg0 arg1 ...]]')
        return
    }
    $command_str = ($args -join ' ') # to surpass the overhead of passing array in `iex @args`
    $start = Get-Date
    Invoke-Expression $command_str
    $end = Get-Date
    Write-Host -ForegroundColor Magenta ('Total Runtime: ' + ($end - $start).TotalSeconds)
}

function gb {
    for ($_dir = "$pwd"; $_dir -and -not $(Test-Path "$_dir/.git/HEAD"); $_dir = Split-Path $_dir) {  }
    if ($_dir) {
        git status
    }
}

function su {
    sudo.exe
}

# Implementation of `systool`

$systool_cmdList = [ordered] @{
    "enable"  = @(
        @{
            "admin"  = {
                sudo -d net user administrator /active:yes
            }
            "hyperv" = {
                sudo -d bcdedit /set hypervisorlaunchtype auto
            }
            "ssh"    = {
                sudo -d net start sshd
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
                sudo -d net user administrator /active:no
            }
            "hyperv" = {
                sudo -d bcdedit /set hypervisorlaunchtype off
            }
            "ssh"    = {
                sudo -d net stop sshd
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
                sudo -d pwsh -nop -nol -c {
                    param($stuff)
                    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name 'PortNumber' -Value $stuff 
                    New-NetFirewallRule -DisplayName 'RDPPORTLatest-TCP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $stuff 
                    New-NetFirewallRule -DisplayName 'RDPPORTLatest-UDP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort $stuff
                } -args $stuff
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
            $notepad_reg_path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"
            $notepad_reg_entry_exist = (Get-ItemProperty -Path $notepad_reg_path | Get-Member | Select-String Debugger)
            if ($stuff -match "restore") {
                if ($notepad_reg_entry_exist) {
                    sudo Remove-ItemProperty -Path $notepad_reg_path -Name Debugger
                }
            } else {
                sudo -d pwsh -nop -c {
                    $notepad_reg_path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"
                    $notepad_reg_entry_exist = (Get-ItemProperty -Path $notepad_reg_path | Get-Member | Select-String Debugger)
                    $my_notepad = $(if (!$stuff) {
                            """D:\Scoop\apps\Notepad2-zufuliu\current\Notepad2.exe"" /z"
                        } else {
                            $stuff
                        })
                    Set-ItemProperty -Path $notepad_reg_path -Name UseFilter -Value 0 -Force  # unset UseFilter, to enable image execution
                    if (!$notepad_reg_entry_exist) {
                        New-ItemProperty -Path $notepad_reg_path -Name Debugger -Value $my_notepad -Force 
                    } else {
                        Set-ItemProperty -Path $notepad_reg_path -Name Debugger -Value $my_notepad -Force
                        [Console]::Write("Debugger is set to ")
                        [Console]::ForegroundColor = [ConsoleColor]::Blue
                        Write-Output $my_notepad
                        [Console]::ResetColor()
                    }
                }
            }
        }
    )
    "fix_wsl" = @(
        @{
            "cuda" = { # WSL2 libcuda.so is not symbolic warning
                sudo -d pwsh -nop -c {
                    Set-Location "C:\Windows\System32\lxss\lib"
                    Remove-Item libcuda.so.1
                    Remove-Item libcuda.so
                    wsl --system -- ln -s libcuda.so.1.1 libcuda.so.1
                    wsl --system -- ln -s libcuda.so.1.1 libcuda.so
                    Write-Output "WSL2 libcuda symbolic is repaired!"
                }
            }

            "ip"   = { # static ip
                # see https://github.com/microsoft/WSL/issues/4210#issuecomment-648570493
                sudo -d pwsh -nop -c {
                    wsl -d Arch -u root ip addr add 172.28.51.142/20 broadcast 172.28.63.255 dev eth0 label eth0:1
                    netsh interface ip add address "vEthernet (WSL)" 172.28.48.1 255.255.240.0
                }
            }
        },
        {
            param([hashtable] $locale_objs = $systool_cmdList.fix_wsl[0])
            if ($locale_objs.ContainsKey($stuff)) {
                &$locale_objs.$stuff
            } else {
                Write-Output "``$stuff`` isn't a valid subcommand of ``fix_wsl``!"
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

function Enable-Choco {
    # Chocolatey profile
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }
}