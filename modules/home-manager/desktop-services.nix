{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.walker.homeManagerModules.default ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  services.hyprpaper.enable = true;
  services.hypridle.enable = true;
  services.network-manager-applet.enable = true;

  services.cliphist.enable = true;

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      terminal = "wezterm";
      theme = "default";
      close_when_open = true;

      builtins = {
        applications.weight = 100;
        websearch.weight = 50;
        websearch.prefix = "?";
        commands.weight = 50;
        commands.prefix = ">";
      };
    };
  };
}

