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
        venv="%F{magenta}>-<%F{blue}conda:$CONDA_DEFAULT_ENV"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        # Strip out the path and just leave the env name
        venv="%F{magenta}>-<%F{blue}venv:${VIRTUAL_ENV##*/}"
    else
        # In case you don't have anyone activated
        venv='' # nothing is shown
    fi
    [[ -n "$venv" ]] && echo "$venv"
}

# no branch dirty check support, I don't feel like neccessary though
function git_prompt_info() {
    local _dir="$PWD"
    local _ret

    while [[ -n "$_dir" && ! -e "$_dir/.git/HEAD" ]]; do
        _dir="${_dir%/*}"
    done

    if [[ -n "$_dir" ]]; then
        _ret=$(basename "$(cat "$_dir/.git/HEAD")")
        if [[ ${#_ret} -ge 20 ]]; then
            _ret="${_ret:0:20}..."
        fi
        
        local GIT_PROMPT_PREFIX="%F{white}-<%F{magenta}"
        local GIT_PROMPT_SUFFIX="%F{white}>"
        
        echo "$GIT_PROMPT_PREFIX$_ret$GIT_PROMPT_SUFFIX"
    else
        echo ""
    fi
}

PS1="%F{white}%B┌<%F{green}%n@%m%F{white}>-<%F{blue}%~%F{white}>$(git_prompt_info)
%b%F{magenta}└<%(?::%B%F{red}×%b%F{magenta}>-<)%F{green}%*$(virtualenv_info)%F{magenta}>->%b%F{white} "
PS2=" %F{magenta}>->>%b%F{white} " # multi-line prompt

