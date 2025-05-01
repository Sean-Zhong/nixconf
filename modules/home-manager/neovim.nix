{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraConfig = ''
    '';
  };

  home.file = {
    ".config/nvim".source = ../../dotfiles/nvim;
  };
}