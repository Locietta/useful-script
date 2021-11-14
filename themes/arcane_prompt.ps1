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
        @("$(($pwd.path.Replace($global:HOME, '~')).TrimEnd('\'))", [ConsoleColor]::Blue),
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
        @((Get-VirtualEnvName), [ConsoleColor]::DarkBlue)
    )
    $script:error_count = $global:error.Count
    [Console]::ForegroundColor = [ConsoleColor]::White; [Console]::Write("`u{250C}");
    Write-PromptGroup -prompt_group $upper_info -separator_color $([ConsoleColor]::White)
    [Console]::WriteLine()
    [Console]::ForegroundColor = [ConsoleColor]::DarkMagenta; [Console]::Write("`u{2514}");
    Write-PromptGroup -prompt_group $lower_info -separator_color $([ConsoleColor]::DarkMagenta)
    [Console]::ForegroundColor = [ConsoleColor]::DarkMagenta; [Console]::Write("->");
    [Console]::ResetColor();
    return " "
}

function Test-Administrator {
    return !([Security.Principal.WindowsIdentity]::GetCurrent().Owner.CompareTo("S-1-5-32-544"))
}

function Get-VirtualEnvName {
    if ($env:VIRTUAL_ENV) {
        return "venv:$($($env:VIRTUAL_ENV -split '\\')[-1].Trim('[\/]'))"
    } elseif ($env:CONDA_DEFAULT_ENV) {
        return "conda:$env:CONDA_DEFAULT_ENV"
    } else {
        return $null
    }
}

function Get-GitBranchQuick { # quickly fetch current git branch 
    for ($_dir = "$pwd"; $_dir -and -not $(Test-Path "$_dir/.git/HEAD"); $_dir = Split-Path $_dir) {  }
    if ($_dir) {
        $ret = (Get-Content "$_dir/.git/HEAD" | Split-Path -Leaf);
        if ($ret.Length -ge 20) { # for detached HEAD or long branch name
            $ret = $ret.Substring(0, 20) + '...'
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
            [void]++$count
        }
    }
    return $count
}

function Write-PromptGroup($prompt_group, [ConsoleColor] $separator_color) {
    $count, $size = 0, $(Get-PromptGroupSize $prompt_group);
    foreach ($e in $prompt_group) {
        if ($e[0]) {
            [Console]::ForegroundColor = $separator_color; [Console]::Write("<");
            [Console]::ForegroundColor = $e[1]; [Console]::Write($e[0]);
            [Console]::ForegroundColor = $separator_color; [Console]::Write(">");
            if (++$count -ne $size) {
                [Console]::ForegroundColor = $separator_color; [Console]::Write("-");
            }
        }
    }
}