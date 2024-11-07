## config for WSL

### Enable WSL

1. `wsl --install  --no-distribution` to update bundled wsl CLI to latest version and install any prerequisites, without installing any distribution.
2. `scoop install archwsl xanmod-WSL2` to install Arch Linux & setup kernel(optional).
3. copy `.wslconfig` to `C:\Users\<username>\.wslconfig`, and in WSL copy `/etc/wsl.conf`.