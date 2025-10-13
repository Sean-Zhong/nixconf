{ pkgs, pkgsUnstable, system, inputs, ... }:
{
    home.packages = with pkgs; [
        jetbrains.idea-ultimate
        sshfs
        fastfetch
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
        playerctl
        parted
        pavucontrol
        hardinfo2
        mangohud
        cookiecutter
        usbimager
        pinta
        libreoffice
        blueberry
        realvnc-vnc-viewer
        inputs.dagger.packages.${system}.dagger
    ];
}

