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
      withRuby = false;
      withPython3 = true;
  };

  home.file = {
    ".config/nvim".source = ../../dotfiles/nvim;
  };

  home.packages = sharedPackages;
}

