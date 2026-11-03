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
                -- If it's already open, do nothing: with `nvim <dir>` the tree has
                -- already taken over the directory window (hijack_directories), and
                -- toggling would close it again.
                if api.tree.is_visible() then
                    return
                end
                -- Otherwise open it; `toggle({ focus = false })` keeps the focus on
                -- the editing window.
                api.tree.toggle({ focus = false })
            end,
        })

        ---------------------------------------------------------------------------
        -- Close NvimTree reliably on quit
        -- - If quitting and only "file + NvimTree" remain, close the tree first.
        -- - If closing a file window leaves only NvimTree, exit Neovim.
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

        -- 2) If closing a file window leaves only the tree, exit Neovim
        -- Only a file window that was just closed counts: the tree is also the only
        -- window when it takes over a directory buffer (`nvim .`, `:e <dir>`), and
        -- that must not quit.
        local file_win_closed = false

        vim.api.nvim_create_autocmd("WinClosed", {
            callback = function(args)
                local win = tonumber(args.match)
                if not (win and vim.api.nvim_win_is_valid(win)) then
                    return
                end
                local floating = vim.api.nvim_win_get_config(win).relative ~= ""
                if floating or is_tree_buf(vim.api.nvim_win_get_buf(win)) then
                    return
                end
                file_win_closed = true
                -- Reset on the next tick: only the BufEnter caused by this close (the
                -- cursor moving to the remaining window) should act on it.
                vim.schedule(function()
                    file_win_closed = false
                end)
            end,
        })

        vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                if not file_win_closed then
                    return
                end
                file_win_closed = false
                -- Check on the next tick: nvim-tree may still be moving windows
                -- around (a file opened in the tree window is moved to a new split by
                -- closing that window and reopening the file).
                vim.schedule(function()
                    local n, tree_win = normal_wins_and_tree_win()
                    if n == 1 and tree_win then
                        vim.cmd("quit")
                    end
                end)
            end,
        })
    end,
}
