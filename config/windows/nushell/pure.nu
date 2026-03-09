# Pure-inspired Nushell prompt (simplified)
# Features:
# - Two-line prompt
# - user@host, current path, and git branch on top line
# - Prompt symbol turns red on non-zero exit code
# - Prompt symbol is prefixed with # when elevated
# - Optional Python env label on second line

# disable the default virtualenv prompt
$env.VIRTUAL_ENV_DISABLE_PROMPT = 1
# To disable default conda env display:
# $ conda config --set changeps1 false

let __pure_admin_probe = (
  do -i {
    ^pwsh -NoLogo -NoProfile -Command "[bool](New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
    | str trim
    | str downcase
  }
  | default "false"
)

$env.PURE_IS_ADMIN = ($__pure_admin_probe == "true")

# Find .git/HEAD by walking upward from the current directory.
def __pure_find_git_head [] {
  mut dir = ($env.PWD | path expand)

  loop {
    let head = ($dir | path join ".git/HEAD")
    if ($head | path exists) {
      return $head
    }

    let parent = ($dir | path dirname)
    if $parent == $dir {
      return ""
    }

    $dir = $parent
  }
}

def __pure_git_branch [] {
  let head = (__pure_find_git_head)
  if ($head | is-empty) {
    return ""
  }

  let raw = (do -i { open $head | str trim } | default "")
  if ($raw | is-empty) {
    return ""
  }

  mut branch = ($raw | path basename)
  if (($branch | str length) >= 20) {
    $branch = $"($branch | str substring 0..19)..."
  }

  $branch
}

def __pure_virtualenv [] {
  let venv_path = ($env.VIRTUAL_ENV? | default "")
  if not ($venv_path | is-empty) {
    return $"venv:($venv_path | path basename)"
  }

  let conda_env = ($env.CONDA_DEFAULT_ENV? | default "")
  if not ($conda_env | is-empty) {
    return $"conda:($conda_env)"
  }

  return ""
}

def __pure_user_host [] {
  let user_candidates = ([$env.USER?, $env.USERNAME?] | compact)
  let host_candidates = ([$env.HOSTNAME?, $env.COMPUTERNAME?] | compact)

  let user = if ($user_candidates | is-empty) {
    "user"
  } else {
    $user_candidates | first
  }

  let host = if ($host_candidates | is-empty) {
    "host"
  } else {
    $host_candidates | first
  }

  $"($user)@($host)"
}

def __pure_path [] {
  let home_candidates = ([$env.HOME?, $env.USERPROFILE?] | compact)
  let home_dir = if ($home_candidates | is-empty) {
    ""
  } else {
    $home_candidates | first
  }

  if ($home_dir | is-empty) {
    $env.PWD
  } else {
    $env.PWD | str replace $home_dir "~"
  }
}

def __pure_prompt_symbol [] {
  let code = ($env.LAST_EXIT_CODE? | default 0)
  let arrow = if $code == 0 {
    $"(ansi magenta)❯(ansi reset)"
  } else {
    $"(ansi red)❯(ansi reset)"
  }

  let admin_prefix = if ($env.PURE_IS_ADMIN? | default false) {
    $"(ansi { fg: '#FFA500' })#(ansi reset)"
  } else {
    ""
  }

  $admin_prefix + $arrow + " "
}

$env.PROMPT_COMMAND = {||
  let user_host_seg = $"(ansi light_green)(__pure_user_host)(ansi reset)"
  let path_seg = $"(ansi light_blue)(__pure_path)(ansi reset)"

  let branch = (__pure_git_branch)
  let git_seg = if ($branch | is-empty) {
    ""
  } else {
    $" (ansi light_magenta)($branch)(ansi reset)"
  }

  let py_env = (__pure_virtualenv)
  let py_seg = if ($py_env | is-empty) {
    ""
  } else {
    $"(ansi light_blue)($py_env)(ansi reset) "
  }

  $"($user_host_seg) ($path_seg)($git_seg)\n($py_seg)"
}

$env.PROMPT_COMMAND_RIGHT = {|| "" }

$env.PROMPT_INDICATOR = {||
  __pure_prompt_symbol
}

$env.PROMPT_MULTILINE_INDICATOR = {|| $"(ansi light_gray)::: (ansi reset)" }

# Keep vi-mode indicators aligned with Pure's default symbols.
$env.PROMPT_INDICATOR_VI_INSERT = {|| __pure_prompt_symbol }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi magenta)❮(ansi reset) " }
