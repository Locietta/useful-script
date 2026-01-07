export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$PATH

eval "$(sheldon source)"

## Legacy Proxy Workaround
#  But it's somehow way faster than WSL's mirrored network mode, so...
export WINHOST=$(ip route show | grep -i default | awk '{ print $3}')
export https_proxy="http://$WINHOST:7890"
export http_proxy=$https_proxy

# mesa can't select d3d12 driver on WSL after 24.3.0
# Ref: https://github.com/microsoft/WSL/issues/12584#issuecomment-2658951125
export GALLIUM_DRIVER=d3d12

# a bug of distrod(#22), see https://github.com/nullpo-head/wsl-distrod/issues/22
export SHELL=/usr/bin/zsh

# OpenSSL 3.0's legacy provider failed to load error on newer Linux distro
# usually encountered while using conda
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# Add wsl shared lib to LD_LIBRARY_PATH, mainly for libcuda.so from wslg
export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH

# systemd & wslg workaround >>>>>
# ln -s /mnt/wslg/.X11-unix/X0 /tmp/.X11-unix/

# for `sudo -e`
export VISUAL="/mnt/d/Scoop/apps/notepad4/current/Notepad4.exe"

##### script wrappers #####

alias ls='eza'
alias grep='grep --color=auto'
alias lf='ls -a'
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
