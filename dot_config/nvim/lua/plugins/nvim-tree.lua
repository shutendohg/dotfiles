-- nvim-tree.lua (Lazy spec)
return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },

    keys = {
        { mode = "n", "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
        { mode = "n", "<C-m>", "<cmd>NvimTreeFocus<CR>",  desc = "Focus on NvimTree" },
        { mode = "n", "<C-p>", "<C-w><C-p>",              desc = "Focus previous window" },
    },

    config = function()
        local tree = require("nvim-tree")

        tree.setup({
            -- --- Core options ------------------------------------------------------
            git = {
                enable = true,
                ignore = true,
            },
            view = {
                side = "left", -- place tree on the left
                preserve_window_proportions = true,
                -- width = 35,                    -- (optional) fixed width
            },
            -- You can add more nvim-tree options here as needed
            -- renderer = { highlight_git = true, ... },

            -- --- Keymaps for the tree buffer --------------------------------------
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return { desc = "NvimTree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                -- Simple file ops
                vim.keymap.set("n", "yy", api.fs.copy.node, opts("Copy"))
                vim.keymap.set("n", "dd", api.fs.remove, opts("Delete"))
                vim.keymap.set("n", "i", api.fs.create, opts("Create"))
                vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))

                -- Navigation
                vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
            end,
        })

        ---------------------------------------------------------------------------
        -- Open tree on startup but keep focus on the editing window (if any)
        -- This mimics "show the tree on launch, don't steal focus".
        ---------------------------------------------------------------------------
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                local api = require("nvim-tree.api")
                -- If it's already open, do nothing; otherwise open without taking focus
                -- Using `toggle({ focus = false })` ensures we don't focus the tree.
                api.tree.toggle({ focus = false })
            end,
        })

        ---------------------------------------------------------------------------
        -- Close NvimTree reliably on quit
        -- - If quitting and only "file + NvimTree" remain, close the tree first.
        -- - If somehow only NvimTree is left, exit Neovim.
        -- Floating windows are ignored in counts to avoid false positives.
        ---------------------------------------------------------------------------
        local function is_tree_buf(buf)
            return vim.bo[buf].filetype == "NvimTree"
        end

        local function normal_wins_and_tree_win()
            local cnt, tree_win = 0, nil
            for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                local cfg = vim.api.nvim_win_get_config(w)
                if cfg.relative == "" then -- normal (non-floating) window
                    cnt = cnt + 1
                    local b = vim.api.nvim_win_get_buf(w)
                    if is_tree_buf(b) then
                        tree_win = w
                    end
                end
            end
            return cnt, tree_win
        end

        -- 1) When quitting and only file+tree remain, close the tree first
        vim.api.nvim_create_autocmd("QuitPre", {
            callback = function()
                local n, tree_win = normal_wins_and_tree_win()
                if n == 2 and tree_win then
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(tree_win) then
                            pcall(vim.api.nvim_win_close, tree_win, true)
                        end
                    end)
                end
            end,
        })

        -- 2) If only the tree is left, exit Neovim
        vim.api.nvim_create_autocmd("BufEnter", {
            nested = true,
            callback = function()
                local n, tree_win = normal_wins_and_tree_win()
                if n == 1 and tree_win then
                    vim.cmd("quit")
                end
            end,
        })
    end,
}
