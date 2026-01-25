{ pkgs }:
with pkgs.vimPlugins; [
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
]
