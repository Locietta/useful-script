# A-bit-like arcaea style theme for zsh @Locietta

# disable the default virtualenv prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# disable default conda env display
# conda config --set changeps1 false

# customized venv-fetcher
function virtualenv_info() {
    # Get Virtual Env
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        # conda env 
        venv="%{$fg[magenta]%}>-<%{\e[34m%}conda:$CONDA_DEFAULT_ENV"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        # Strip out the path and just leave the env name
        venv="%{$fg[magenta]%}>-<%{\e[34m%}venv:${VIRTUAL_ENV##*/}"
    else
        # In case you don't have anyone activated
        venv='' # nothing is shown
    fi
    [[ -n "$venv" ]] && echo "$venv"
}

PROMPT=$'%{$fg_bold[white]%}┌<%{$fg_bold[green]%}%n@%m%{$fg[white]%}>-<%{\e[34m%}%~%{$fg[white]%}>$(git_prompt_info)
%{$reset_color%}%{$fg[magenta]%}└<%(?::%{$fg_bold[red]%}×%{$reset_color%}%{$fg[magenta]%}>-<)%{$fg[green]%}%*$(virtualenv_info)%{$fg[magenta]%}>->%{$reset_color%} '
PS2=$' %{$fg[magenta]%}>->>%{$reset_color%} ' # multi-line prompt

# config git prompt
# -----------------
# git prompt will be shown in the format below 👇
# $ZSH_THEME_GIT_PROMPT_PREFIX$ref$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX
# 
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[white]%}-<%{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[white]%}>%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""