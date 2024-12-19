# switch encoding to UTF-8
# didn't seem to work
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(65001)
$env:LANG="zh_CN.UTF-8"

# PROXY (not using socks5 because some tools don't support it, e.g. aria2#153)
$Env:http_proxy="http://127.0.0.1:7890";$Env:https_proxy="$Env:http_proxy"

# custom prompt
. $env:UtilScriptDir\config\windows\arcane_prompt.ps1

# custom functions
. $env:UtilScriptDir\pwsh_utility.ps1

# Hook `scoop search`
function scoop { if ($args[0] -eq "search") { scoop-search.exe @($args | Select-Object -Skip 1) } else { scoop.ps1 @args } }

# PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

$forbid_alias_list = @("ls", "rm", "where", "cp", "diff")
# $msys2_export_list = @("pacman", "makepkg")

foreach ($alias in $forbid_alias_list) {
  Remove-Item -Path "Alias:\$alias" -Force
}

function wh { Write-Host @args }

function Archi {
  D:\Scoop\apps\archwsl\current\Arch.exe $args
}

function mklink { # warp mklink into pwsh
  cmd /c mklink $args
}

function su { sudo }