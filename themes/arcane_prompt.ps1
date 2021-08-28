# Native custom powershell prompt, faster than Oh-My-Posh(V2&V3) prompt
# I'm now using this ^_^
# 
# NOTE: To use the prompt, source this file in your profile.

#Requires -Version 7
$error_count = 0;
function prompt {
    $last_cmd_failed = (!$?) -or ($global:error.Count -gt $script:error_count)
    $upper_info = @(
        # Host
        @("$env:USERNAME@$env:COMPUTERNAME", [ConsoleColor]::Green),
        # Current Path
        @("$(Get-FullPath -dir $pwd)", [ConsoleColor]::Blue),
        # Git Status
        @( if ($status = Get-GitBranchQuick) { "git:$status" } else { $null }, [ConsoleColor]::Magenta)
    );
    $lower_info = @(
        # Check the last command state and indicate if failed 
        @(if ($last_cmd_failed) { "`u{274C}" } else { $null; }, [ConsoleColor]::DarkRed), # use `[char]::ConvertFromUtf32(0x274C)` in powershell 5
        # Check for elevated prompt
        @(if (Test-Administrator) { "`u{26A1}" } else { $null }, [ConsoleColor]::DarkYellow),
        # Current time
        @("$(Get-Date -Format HH:mm:ss)", [ConsoleColor]::DarkGreen),
        # Virtual environment
        @(if (Test-VirtualEnv) { "env:$(Get-VirtualEnvName)" } else { $null }, [ConsoleColor]::DarkBlue)
    )
    $script:error_count = $global:error.Count
    Write-Host "`u{250C}" -NoNewline -ForegroundColor $([ConsoleColor]::White)
    Write-PromptGroup -prompt_group $upper_info -separator_color $([ConsoleColor]::White)
    Set-Newline
    Write-Host "`u{2514}" -NoNewline -ForegroundColor $([ConsoleColor]::DarkMagenta)
    Write-PromptGroup -prompt_group $lower_info -separator_color $([ConsoleColor]::DarkMagenta)
    Write-Host "->" -NoNewline -ForegroundColor $([ConsoleColor]::DarkMagenta)
    return " "
}
        
function Get-GitBranchQuick { # quickly fetch current git branch 
    for ($_dir = "$pwd"; $_dir -and -not $(Test-Path "$_dir/.git/HEAD"); $_dir = Split-Path $_dir) {  }
    if ($_dir) {
        $ret = (Get-Content "$_dir/.git/HEAD" | Split-Path -Leaf);
        if ($ret.Length -ge 8) { # for detached HEAD or long branch name
            $ret = $ret.Substring(0, 8) + '...'
        }
        return $ret
    } else {
        return ''
    }
}

# counting size of prompt group
function Get-PromptGroupSize($prompt_group) {
    $count = 0;
    foreach ($e in $prompt_group) {
        if ($e[0]) {
            ++$count
        }
    }
    return $count
}

function Write-PromptGroup($prompt_group, [ConsoleColor] $separator_color) {
    $count, $size = 0, $(Get-PromptGroupSize $prompt_group);
    foreach ($e in $prompt_group) {
        if ($e[0]) {
            Write-Host '<' -NoNewline -ForegroundColor $separator_color;
            Write-Host $e[0] -NoNewline -ForegroundColor $e[1];
            Write-Host '>' -NoNewline -ForegroundColor $separator_color;
            if (++$count -ne $size) {
                Write-Host '-' -NoNewline -ForegroundColor $separator_color;
            }
        }
    }
}