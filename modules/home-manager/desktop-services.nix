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

  # 2. Configure Walker natively
  programs.walker = {
    enable = true;
    runAsService = true; # Automatically spins up the Elephant backend natively!

    config = {
      terminal = "wezterm";
      theme = "default";
      
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

