{ pkgs, pkgsUnstable, ... }:
{
    home.packages = with pkgs; [
        jetbrains.idea-ultimate
        sshfs
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
        kubectl
        playerctl
        parted
        pavucontrol
        talosctl
        hardinfo2
        kubernetes-helm
        mangohud
    ];
}

