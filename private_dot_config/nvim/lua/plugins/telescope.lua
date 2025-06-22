return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files)
        vim.keymap.set('n', '<leader>fg', builtin.live_grep)
        vim.keymap.set('n', '<leader>fh', builtin.help_tags)
        vim.keymap.set('n', '<leader>gb', builtin.git_branches)
        vim.keymap.set('n', '<leader>bf', '<cmd>lua require("telescope.builtin").buffers()<cr>', { noremap = true })
    end
}
