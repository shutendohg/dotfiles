-- plugins/telescope-file-browser.lua
return {
    "nvim-telescope/telescope-file-browser.nvim",
    version = "*",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },

    -- ★ これだけで <leader>fb を押した瞬間にロード & 実行
    keys = {
        { "<leader>fb", "<cmd>Telescope file_browser<CR>", desc = "File Browser" },
    },

    config = function()
        require("telescope").setup({
            extensions = {
                file_browser = {
                    theme = "ivy",
                    hijack_netrw = true,
                    hidden = true,
                },
            },
        })
        require("telescope").load_extension("file_browser")
    end,
}
