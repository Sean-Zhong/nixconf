{ pkgs, ... }:
let
  sharedPlugins = import ../../dotfiles/nvim/nix/plugins.nix { inherit pkgs; };
  sharedPackages = import ../../dotfiles/nvim/nix/dependencies.nix { inherit pkgs; };
in
{
    programs.neovim = {
      enable = true;
      extraLuaPackages = ps: [ ps.magick ];
      extraConfig = ''
      '';
      plugins = sharedPlugins;
  };

  home.file = {
    ".config/nvim".source = ../../dotfiles/nvim;
  };

  home.packages = sharedPackages;
}

