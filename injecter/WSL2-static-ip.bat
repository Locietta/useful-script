@REM from https://github.com/microsoft/WSL/issues/4210#issuecomment-648570493

wsl -d Arch -u root ip addr add 172.28.51.142/20 broadcast 172.28.63.255 dev eth0 label eth0:1

netsh interface ip add address "vEthernet (WSL)" 172.28.48.1 255.255.240.0