{ config, pkgs, inputs, outputs, ... }:

{
  imports = [ 
    ../../modules/home-manager/wezterm.nix
    # ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/java.nix
    ../../modules/home-manager/gtk.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/programs.nix
    ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  programs.git = {
      enable = true;
      userName = "Sean Zhong";
      userEmail = "sean.zhong98@gmail.se";
    };

  programs.tmux = {
    enable = true;
  };
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake /home/sean/nixconf/#desktop";
    };
    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";

    plugins = [
      {
        name = "nix-shell";
        src = pkgs.zsh-nix-shell;
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ../../dotfiles/p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
    ];

    #plugins
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
      ];
    };
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
