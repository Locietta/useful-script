# source this file in your pwsh profile

#Requires -Version 6

# use `imagemagick` package as the converter
# you can obtain it via `Scoop` package manager or MSYS2(with `pacman -S mingw-w64-x86_64-imagemagick`)
# for more details, go to its official website (https://imagemagick.org/)
$ico_converter = "D:\Scoop\apps\imagemagick\current\convert.exe"

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
        [string] $output_file = "$(
            if ($input_file) {
                $(Split-Path -Path $input_file -Parent)/$(Split-Path -Path $input_file -LeafBase).ico
            } else {
                $null
            })
        "
    )
    # TODO: handle pipe
    if (!$input_file) {
        return "You must specify a PNG file to be converted."
    }

    &$ico_converter $input_file -define icon:auto-resize=256,64,48,32,16 $output_file
}