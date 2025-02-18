### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

## Load ZSH plugins

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/completion.zsh

export PATH=$HOME/.local/bin:$PATH

## Legacy Proxy Workaround
#  But it's somehow way faster than WSL's mirrored network mode, so...
export WINHOST=$(ip route show | grep -i default | awk '{ print $3}')
export https_proxy="http://$WINHOST:7890"
export http_proxy=$https_proxy

# a bug of distrod(#22), see https://github.com/nullpo-head/wsl-distrod/issues/22
export SHELL=/usr/bin/zsh

# OpenSSL 3.0's legacy provider failed to load error on newer Linux distro
# usually encountered while using conda
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# systemd & wslg workaround >>>>>
# ln -s /mnt/wslg/.X11-unix/X0 /tmp/.X11-unix/

# for `sudo -e`
export VISUAL="/mnt/d/Scoop/apps/notepad4/current/Notepad4.exe"

##### script wrappers #####

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lf='ls --color=auto -a'
alias ll='ls --color=auto -al'
alias vi=vim

alias code="/mnt/d/Scoop/apps/vscode/current/bin/code"
# enter into systemd shell
alias sysd='sudo subsystemctl shell --uid=1000 --start'
# Notepad4 alias
alias notepad="$VISUAL"
# windows style clear terminal
alias cls="clear"
# eza, ls-next
alias e="eza"

## Custom Prompt
setopt PROMPT_SUBST
source $HOME/.config/arcane.zsh

## Manually enable auto-comp
autoload -Uz compinit
compinit
