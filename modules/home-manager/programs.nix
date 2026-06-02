{ pkgs, pkgsUnstable, system, inputs, ... }:
{
    home.packages = with pkgs; [
        fastfetch
        keepassxc
        filezilla
        gnomeExtensions.forge
        gnomeExtensions.app-icons-taskbar
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
        davinci-resolve
        zoom-us
        orca-slicer
    ];
}

