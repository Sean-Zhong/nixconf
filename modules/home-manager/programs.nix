{ pkgs, pkgsUnstable, system, inputs, ... }:
{
    home.packages = with pkgs; [
        fastfetch
        keepassxc
        filezilla
        gnomeExtensions.forge
        gnomeExtensions.app-icons-taskbar
        youtube-music
        solaar
        remmina
        playerctl
        parted
        pavucontrol
        hardinfo2
        mangohud
        usbimager
        pinta
        libreoffice
        blueberry
        realvnc-vnc-viewer
    ];
}

