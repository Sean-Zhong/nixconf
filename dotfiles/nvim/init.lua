require("vim-options")
require("plugins/telescope")
require("plugins/treesitter")
require("plugins/lualine")
require("plugins/lsp-config")
require("plugins/completions")
require("plugins/image")
require("plugins/oil-nvim")
require("catppuccin").setup({
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
})

vim.cmd.colorscheme "catppuccin"

