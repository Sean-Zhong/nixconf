{ pkgs, pkgsUnstable, ... }:
{
    home.packages = with pkgs; [
        kubectl
        pkgsUnstable.talosctl
        kubernetes-helm
        fluxcd
        sops
        gnupg
        age
    ];
}


