{ pkgs }:

pkgs.writeShellScriptBin "mountdata" ''
sudo umount /mnt/team_files
sudo sshfs -o allow_other,identityfile=/home/sean/.ssh/id_ed25519,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 \
    sean.zhong@team-flow-1.int.scila.se:/custdata/ \
    /mnt/team_files

sudo umount /mnt/dolph_files
sudo mount -t cifs //dolph.int.scila.se/files /mnt/dolph_files -o guest,uid=1000,iocharset=utf8
''