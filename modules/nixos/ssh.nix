{ pkgs, home, ... }:

{
    programs.ssh.startAgent = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.hyprland.enableGnomeKeyring = true;
    programs.seahorse.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;
}
