start /B "loia@Osaka" "%ProgramFiles%\SSHFS-Win\bin\sshfs-win.exe" svc \sshfs.k\loia@Osaka X: "-o ServerAliveInterval=30"
start /B "root@Osaka" "%ProgramFiles%\SSHFS-Win\bin\sshfs-win.exe" svc \sshfs.kr\root@Osaka Y: "-o ServerAliveInterval=30"
start /B "shadiao@shadiao" "%ProgramFiles%\SSHFS-Win\bin\sshfs-win.exe" svc \sshfs.k\shadiao@shadiao Z: "-o ServerAliveInterval=30"
