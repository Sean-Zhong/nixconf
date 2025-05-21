{ config, pkgs, inputs, ... }:

{
  imports = [ 
    ../../modules/home-manager/wezterm.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/java.nix
    ../../modules/home-manager/gtk.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/antivirus.nix
    ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  programs.git = {
      enable = true;
      userName = "Sean Zhong";
      userEmail = "sean.zhong@scila.se";
    };

  programs.tmux = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  home.file = {
    "jdks/temurin11".source = pkgs.temurin-bin-11;
    "jdks/temurin17".source = pkgs.temurin-bin-17;
    "jdks/temurin21".source = pkgs.temurin-bin;
    "jdks/graalvm-ce".source = pkgs.graalvm-ce;
    "jdks/jetbrains".source = pkgs.jetbrains.jdk;
    ".config/hypr".source = ../../dotfiles/hypr;
    ".config/hyprmodules".source = ./hyprmodules;
    ".config/waybar".source = ../../dotfiles/waybar;
    "resources/images".source = ../../resources/images;
    ".config/wofi".source = ../../dotfiles/wofi;
    "scripts".source = ../../dotfiles/scripts; 
    };

  home.sessionVariables = {
    SSH_AUTH_SOCK= "/run/user/1000/keyring/ssh";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
