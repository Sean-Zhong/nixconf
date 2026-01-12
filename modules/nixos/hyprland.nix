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

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      libpinyin
    ];
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    GLFW_IM_MODULE = "ibus"; 
  };

  programs.dconf.enable = true;
}

