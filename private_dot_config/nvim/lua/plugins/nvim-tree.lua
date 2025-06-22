return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { mode = "n", "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
        { mode = "n", "<C-m>", "<cmd>NvimTreeFocus<CR>",  desc = "Focus on NvimTree" },
    },
    config = function()
        local tree = require("nvim-tree")

        tree.setup({
            git = {
                enable = true,
                ignore = true,
            },
            view = {
                preserve_window_proportions = true,
            },
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                -- copy by yy
                vim.keymap.set('n', 'yy', api.fs.copy.node, opts('Copy'))
                -- delete by dd
                vim.keymap.set('n', 'dd', api.fs.remove, opts('Delete'))
                -- create new file by i
                vim.keymap.set('n', 'i', api.fs.create, opts('Create'))
                -- paste by p
                vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))

                -- Redefine default key mapping
                vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
                vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
                vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
            end,
        })

        -- Focus opening file not nvim-tree
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                local api = require("nvim-tree.api")
                api.tree.toggle({ focus = false })
            end,
        })

        -- quit vim when nvim-tree is only left.
        vim.api.nvim_create_autocmd("BufEnter", {
            nested = true,
            callback = function()
                if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
                    vim.cmd("quit")
                end
            end,
        })

        -- Move editing files without closing nvim-tree
        vim.keymap.set('n', '<C-p>', '<C-w><C-p>', { desc = "Focus previous window" })
    end,
}
