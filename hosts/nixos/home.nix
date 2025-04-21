{ config, pkgs, inputs, ... }:
  let
    startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
      ${pkgs.waybar}/bin/waybar &
      ${pkgs.swww}/bin/swww init &
  
      sleep 1
    '';
  in
  # ${pkgs.swww}/bin/swww img ${../../resources/images/wallpaper.jpg} &
{
  imports = [ 
    ../../modules/home-manager/wezterm.nix
    ../../modules/home-manager/zsh.nix
    # ../../modules/home-manager/hyprland.nix
    # ../../modules/home-manager/java.nix
    ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
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

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.maven
    pkgs.gradle
    pkgs.jdk17        #graalvm-ce
    pkgs.java-language-server
    pkgs.jdt-language-server

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    # fonts
  ];

  # fonts.packages = [
  #   pkgs.nerd-fonts.JetBrainsMono
  # ];
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    "jdks/temurin11".source = pkgs.temurin-bin-11;
    "jdks/temurin17".source = pkgs.temurin-bin-17;
    "jdks/temurin21".source = pkgs.temurin-bin;
    "jdks/graalvm-ce".source = pkgs.graalvm-ce;
    "jdks/jetbrains".source = pkgs.jetbrains.jdk;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sean/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    JAVA_11_HOME = "$HOME/jdks/temurin11";
    JAVA_17_HOME = "$HOME/jdks/temurin17";
    JAVA_21_HOME = "$HOME/jdks/temurin21";
    GRAAL_HOME = "$HOME/jdks/graalvm-ce";
    JETBRAINS_CLIENT_JDK = "$HOME/jdks/jetbrains";
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;

    settings = builtins.readFile ../../dotfiles/hyprland/hyprland.conf;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
