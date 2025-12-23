{ config, pkgs, inputs, outputs, ... }:

{
  imports = [
    ../../modules/home-manager/wezterm.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/java.nix
    ../../modules/home-manager/gtk.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/antivirus.nix
    ../../modules/home-manager/programs.nix
    ../../modules/home-manager/zenbrowser.nix
    ../../modules/home-manager/kubernetes.nix
    ../../modules/home-manager/ssh.nix
    ../../modules/home-manager/vpn-toggle.nix
    ../../modules/home-manager/development.nix
    ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  programs.git = {
    enable = true;
    settings.user.name = "Sean Zhong";
    settings.user.email = "sean.zhong@scila.se";
  };

  programs.tmux = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  home.file = {
    ".config/hypr".source = ../../dotfiles/hypr;
    ".config/hyprmodules".source = ./hyprmodules;
    ".config/waybar".source = ../../dotfiles/waybar;
    "resources/images".source = ../../resources/images;
    ".config/wofi".source = ../../dotfiles/wofi;
    "scripts".source = ../../dotfiles/scripts; 
    };

  programs.home-manager.enable = true;
}
