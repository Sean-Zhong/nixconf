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

  programs.neovim.plugins = with pkgs.vimPlugins; [
    catppuccin-nvim
    telescope-nvim
    nvim-treesitter.withAllGrammars
    neo-tree-nvim
    lualine-nvim
  ];
}
