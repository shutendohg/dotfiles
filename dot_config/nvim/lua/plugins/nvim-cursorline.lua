return {
    {
        "ya2s/nvim-cursorline",
        cond = function()
            return not vim.tbl_contains(vim.v.argv, "-b")
        end,
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-cursorline").setup({
                disable_filetypes = {
                    "NvimTree",
                    "Trouble",
                    "qf",
                    "help",
                    "TelescopePrompt",
                    "lazy",
                    "mason",
                    "xxd",
                    "hex",
                },
                disable_buftypes = {
                    "terminal",
                    "prompt",
                    "nofile",
                    "quickfix",
                    "help",
                },
                cursorline = {
                    enable = true,
                    timeout = 0,
                    number = false,
                },
                cursorword = {
                    enable = true,
                    min_length = 3,
                    hl = { underline = true },
                },
            })
        end,
    },
}
