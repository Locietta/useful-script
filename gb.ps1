function Get-GitBranchQuick { 
    # see https://gist.github.com/bingzhangdai/dd4e283a14290c079a76c4ba17f19d69 for bash script version
    $_head_file = "";
    $_dir = "$pwd";
    
    while ($_dir) {
        $_head_file = "$_dir/.git/HEAD";
        if (Test-Path $_head_file) {
            break;
        } else {
            $_dir = Split-Path $_dir;
        }
    }
    
    if ($_dir) {
        $ret = (Get-Content $_head_file | Split-Path -Leaf);
        if ($ret.Length -ge 8) { # for detached HEAD or long branch name
            $ret = $ret.Substring(0, 8) + '...'
        }
        return $ret
    } else {
        return ''
    }
}

if (Get-GitBranchQuick) {git status};