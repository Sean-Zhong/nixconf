{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    waybar
    swaynotificationcenter
    networkmanagerapplet
    libnotify
    swww
    hyprpaper
    wofi
    hyprshot
    hyprlock
    hypridle
    hyprcursor
    wlogout
    blueman
    wl-clipboard
    cliphist
    hyprpolkitagent
    hyprsunset
    hyprsysteminfo
    grim
    slurp
    swappy
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
