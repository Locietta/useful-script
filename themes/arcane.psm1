# Oh-My-Posh V3 themes loads faster than V2 themes when opening a new POSH window, but they write prompts slower
# And V3 is somehow unable to colorize a text containing '<' (a bug maybe), so I'll still stay at V2 for some time

# use `Get-GitBranchQuick`(1~3ms) to replace `Get-VCSStatus`(60+ms), for faster prompt generates.

# see https://gist.github.com/bingzhangdai/dd4e283a14290c079a76c4ba17f19d69 for bash script version
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

function Write-Theme([bool] $lastCommandFailed, [string] $with) {
    # ┌
    $prompt = Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C)) -ForegroundColor $sl.Colors.PromptSymbolColorUpper

    # Host
    $user = $sl.CurrentUser
    $computer = $sl.CurrentHostname
    $prompt += Write-UpperSegment -content "$user@$computer" -foregroundColor $sl.Colors.HostForegroundColor

    # Current path
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColorUpper
    $path += Get-FullPath -dir $pwd
    $prompt += Write-Prompt -Object $path -ForegroundColor $sl.Colors.PathForegroundColor
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColorUpper
    
    # Version Control Status<git:branchname> 
    # $status = Invoke-Expression "git symbolic-ref --short -q HEAD;" # 20ms faster than `Get-VCSStatus`
    $status = Get-GitBranchQuick;
    if ($status) {
        $prompt += Write-Prompt -Object "-$($sl.PromptSymbols.SegmentBackwardSymbol)" -ForegroundColor $sl.Colors.PromptSymbolColorUpper
        $prompt += Write-Prompt -Object "git:$status" -foregroundColor $sl.Colors.GitForegroundColor;
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColorUpper
    }

    $prompt += ''

    # SECOND LINE
    $prompt += Set-Newline
    $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.Colors.PromptSymbolColorLower
    
    #check the last command state and indicate if failed
    if ($lastCommandFailed) {
        $prompt += Write-LowerSegment -content $sl.PromptSymbols.FailedCommandSymbol -foregroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    #check for elevated prompt
    if (Test-Administrator) {
        $prompt += Write-LowerSegment -content $sl.PromptSymbols.ElevatedSymbol -foregroundColor $sl.Colors.AdminIconForegroundColor
    }

    # Current time
    $prompt += Write-LowerSegment -content $(Get-Date -Format HH:mm:ss) -ForegroundColor $sl.Colors.TimeForegroundColor

    # Virtual environment
    if (Test-VirtualEnv) {
        $prompt += Write-LowerSegment -content "env:$(Get-VirtualEnvName)" -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) $($sl.PromptSymbols.SegmentBackwardSymbol)" -ForegroundColor $sl.Colors.PromptSymbolColor
        $prompt += Write-Prompt -Object "$($with.ToUpper())" -ForegroundColor $sl.Colors.WithForegroundColor
    }

    $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptIndicator)" -ForegroundColor $sl.Colors.PromptSymbolColorLower
    $prompt += ' '
    $prompt
}

# Use these function to write <>-
function Write-UpperSegment($content, $foregroundColor) {
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColorUpper
    $prompt += Write-Prompt -Object $content -ForegroundColor $foregroundColor
    $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol)-" -ForegroundColor $sl.Colors.PromptSymbolColorUpper
    return $prompt
}

function Write-LowerSegment($content, $foregroundColor) {
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.PromptSymbolColorLower
    $prompt += Write-Prompt -Object $content -ForegroundColor $foregroundColor
    $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol)-" -ForegroundColor $sl.Colors.PromptSymbolColorLower
    return $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = '>'
$sl.PromptSymbols.SegmentForwardSymbol = '>'
$sl.PromptSymbols.SegmentBackwardSymbol = '<'
$sl.PromptSymbols.PathSeparator = '\'
$sl.PromptSymbols.FailedCommandSymbol = [char]::ConvertFromUtf32(0x274C)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::DarkBlue
$sl.Colors.PromptSymbolColorUpper = [ConsoleColor]::White
$sl.Colors.PromptSymbolColorLower = [ConsoleColor]::DarkMagenta
$sl.Colors.HostForegroundColor = [ConsoleColor]::Green
$sl.Colors.PathForegroundColor = [ConsoleColor]::Blue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Magenta
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkYellow
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.TimeForegroundColor = [ConsoleColor]::DarkGreen
$sl.Colors.VirtualEnvForegroundColor = [ConsoleColor]::DarkBlue