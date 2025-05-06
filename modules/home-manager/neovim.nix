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
    nvim-lspconfig
  ];

  home.packages = with pkgs; [
    lua-language-server
    nixd
    bash-language-server
    typescript-language-server
    yaml-language-server
  ];
}
