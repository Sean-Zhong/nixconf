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
    uwsm
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
    brightnessctl
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
