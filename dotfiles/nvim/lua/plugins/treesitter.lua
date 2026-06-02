
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local buf = args.buf
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return 
        end

        pcall(vim.treesitter.start, buf)

        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
