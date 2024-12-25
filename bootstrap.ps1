# NOTE: 
# * Requires administrative privileges
# * Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` to allow running PS scripts
# * Assumed proxy settings are already configured

# Detect if run under admin privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as administrator!" -ForegroundColor Red
    exit
}

# Install Scoop
Invoke-RestMethod get.scoop.sh -outfile 'scoop_install.ps1'
.\scoop_install.ps1 -ScoopDir 'D:\Scoop' -ScoopGlobalDir 'D:\Scoop\global'
Remove-Item -Path 'scoop_install.ps1' -Force
scoop install git 
scoop update # scoop update relies on git
scoop bucket add Extras
scoop bucket add sniffer https://github.com/Locietta/sniffer
scoop install gsudo sfsu autohotkey which bat ripgrep fd sniffer/notepad4 sniffer/pasteex pwsh

# Enable Long Path Support
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# Enable Developer Mode
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1

### Write PATH
$pathsToCheck = @($PSScriptRoot, "$PSScriptRoot\wrappers", "D:\Scoop\shims")
$currentPaths = $env:PATH.Split(';')

# Filter out paths that are already in the PATH
$pathsToAdd = $pathsToCheck | Where-Object { $currentPaths -notcontains $_ }

$currentSystemPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
$newSystemPath = $currentSystemPath
foreach ($path in $pathsToAdd) {
    $newSystemPath += ";$path"
}

[System.Environment]::SetEnvironmentVariable(
    "PATH", 
    $newSystemPath,
    [System.EnvironmentVariableTarget]::Machine
)

[System.Environment]::SetEnvironmentVariable(
    "UtilScriptDir", 
    $PSScriptRoot,
    [System.EnvironmentVariableTarget]::Machine
)


# Set MSYS2 path, so we can use it in the wrappers
# TODO: detect it automatically, now MSYS2 has to be installed at D:\msys64
[System.Environment]::SetEnvironmentVariable(
    "MSYS2", 
    "D:\msys64",
    [System.EnvironmentVariableTarget]::Machine
)

# symlink ahk scripts to startup, so they run on boot
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
New-Item -ItemType SymbolicLink -Path "$startup\elevated_keymap.ahk2" -Target "$PSScriptRoot\elevated_keymap.ahk2"
New-Item -ItemType SymbolicLink -Path "$startup\keymap.ahk2" -Target "$PSScriptRoot\keymap.ahk2"

# symlink config files to their respective places
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.gitconfig" -Target "$PSScriptRoot\config\windows\.gitconfig"

# symlink $PROFILE, need to create folder first
$DocumentFolder = [Environment]::GetFolderPath("MyDocuments")
New-Item -ItemType Directory -Force -Path "$DocumentFolder\PowerShell"
New-Item -ItemType SymbolicLink -Path "$DocumentFolder\PowerShell\Microsoft.PowerShell_profile.ps1" -Target "$PSScriptRoot\config\windows\Microsoft.PowerShell_profile.ps1"

