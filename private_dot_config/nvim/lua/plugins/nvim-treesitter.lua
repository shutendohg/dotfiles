return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate", -- Automatic update after installing
        lazy = false,
        config = function()
            require("config.treesitter") -- Separating config file
        end,
    },
}
