return {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    config  = function()
        require("nvim-surround").setup({
            -- User can add custom command here
        })
    end,
}
