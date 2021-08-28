function Get-GitBranchQuick { # quickly fetch current git branch 
    # see https://gist.github.com/bingzhangdai/dd4e283a14290c079a76c4ba17f19d69 for bash script version
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

if (Get-GitBranchQuick) {git status};