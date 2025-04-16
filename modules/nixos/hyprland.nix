{ pkgs, lib, config, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.waybar
    pkgs.dunst
    pkgs.networkmanagerapplet
    libnotify
    swww
    wofi
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}