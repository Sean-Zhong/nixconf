{ pkgs, lib, config, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    waybar
    dunst
    networkmanagerapplet
    libnotify
    swww
    hyprpaper
    wofi
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