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