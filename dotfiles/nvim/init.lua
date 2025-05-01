vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

local options = {
    mouse = "a",
    cursorline = true,
    termguicolors = true,
    guifont = "monospace:h17", -- Emojis
    number = true, -- Linenumbers
    list = true,
    scrolloff = 999, -- Keeps cursor in the middle
    relativenumber = true, -- Linenumbers gets relative to current pos
    colorcolumn = '80',
    showtabline = 2,
    showmode = false, -- Lualine shows this anyway
}

for k,v in pairs(options) do
    vim.opt[k] = v
end

vim.cmd.colorscheme "catppuccin"

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
--vim.keymap.set('n', ')
