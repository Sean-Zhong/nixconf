{ pkgs, ... }:
{
    home.packages = with pkgs; [
        jetbrains.idea-ultimate
        sshfs
        cifs-utils
        neofetch
        keepassxc
        filezilla
        gnomeExtensions.forge
        gnomeExtensions.app-icons-taskbar
        youtube-music
        vscode-fhs
        openssh
        wezterm
        devpod
        jetbrains.gateway
        go
        solaar
        remmina
        ripgrep
        binutils
        bambu-studio
    ];
}

