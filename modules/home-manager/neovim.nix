{ pkgs, ... }:

{
    programs.neovim = {
      enable = true;
      extraLuaPackages = ps: [ ps.magick ];
      extraPackages = [ pkgs.imagemagick ];
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
    plenary-nvim
    neo-tree-nvim
    nvim-web-devicons
    lualine-nvim
    nvim-lspconfig
    nui-nvim
    nvim-cmp
    luasnip
    cmp_luasnip
    friendly-snippets
    cmp-nvim-lsp
    image-nvim
    oil-nvim
  ];

  home.packages = with pkgs; [
    lua-language-server
    nixd
    bash-language-server
    typescript-language-server
    yaml-language-server
    typst
    ueberzugpp
  ];
}
