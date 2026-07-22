{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.walker.homeManagerModules.default ];

    #  programs.waybar = {
    #    enable = true;
    #    systemd.enable = true;
    #  };

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell Wayland Desktop Bar";
      Documentation = "https://quickshell.outfoxxed.me/";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.uwsm}/bin/uwsm app -- ${pkgs.quickshell}/bin/quickshell";

      Restart = "on-failure";
      RestartSec = "1s";

      KillMode = "mixed";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  services.hyprpaper.enable = true;
  services.hypridle.enable = true;
  services.network-manager-applet.enable = true;

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

        clipboard = {
          weight = 80;
          clear_query_on_select = true;
        };
      };

      providers.actions = {
        clipboard = [
          { action = "copy"; bind = "Return"; default = true; }
          { action = "remove"; bind = "ctrl d"; after = "ClearReload"; }
          { action = "remove_all"; global = true; bind = "ctrl shift d"; after = "ClearReload"; }
        ];
      };
    };
  };
}
