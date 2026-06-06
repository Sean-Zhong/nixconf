{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  services.hyprpaper.enable = true;
  services.hypridle.enable = true;
  services.network-manager-applet.enable = true;

  services.cliphist.enable = true;

  xdg.configFile."autostart/hyprpolkitagent.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';
}

