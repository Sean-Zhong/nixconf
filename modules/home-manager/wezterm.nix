{ pkgs, ... }:

{
  home.packages = with pkgs; [ wezterm ];

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = builtins.readFile ../../dotfiles/wezterm/wezterm.lua;
  };
}
