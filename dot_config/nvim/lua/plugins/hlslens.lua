return {
    {
        "kevinhwang91/nvim-hlslens",
        event = "CmdlineEnter",
        config = function()
            require('hlslens').setup()

            local kopts = { noremap = true, silent = true }

            vim.api.nvim_set_keymap('n', 'n',
                [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
                kopts)
            vim.api.nvim_set_keymap('n', 'N',
                [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
                kopts)
            vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

            -- Clear the highlight
            vim.api.nvim_set_keymap('n', '<Esc>',
                [[<Cmd>noh<CR><Cmd>lua require('hlslens').stop()<CR>]], kopts)
        end
    }
}
