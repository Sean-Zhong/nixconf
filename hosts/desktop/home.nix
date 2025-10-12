{ config, pkgs, inputs, outputs, ... }:

{
  imports = [ 
    ../../modules/home-manager/wezterm.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/java.nix
    ../../modules/home-manager/gtk.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/programs.nix
    ../../modules/home-manager/zenbrowser.nix
    ../../modules/home-manager/kubernetes.nix
    ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  programs.git = {
      enable = true;
      userName = "Sean Zhong";
      userEmail = "sean.zhong98@gmail.com";
    };

  programs.tmux = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

   home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.maven
    pkgs.gradle
    pkgs.jdk17
    pkgs.java-language-server
    pkgs.jdt-language-server
  ];

  home.file = {
    ".config/hypr".source = ../../dotfiles/hypr;
    ".config/hyprmodules".source = ./hyprmodules;
    ".config/waybar".source = ../../dotfiles/waybar;
    "resources/images".source = ../../resources/images;
    ".config/wofi".source = ../../dotfiles/wofi;
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK= "/run/user/1000/keyring/ssh";
    TALOSCONFIG="/home/sean/Projects/talos-config/rendered/talosconfig";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
