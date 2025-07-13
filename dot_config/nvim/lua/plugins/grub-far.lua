return {
    "MagicDuck/grug-far.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("grug-far").setup({})
    end,
    keys = {
        {
            "<leader>sr",
            function()
                require("grug-far").open({
                    window = {
                        position = "bottom",
                        height = 15,
                    },
                })
            end,
            desc = "GrugFar: Search and Replace (bottom)",
        },
    },
    cmd = { "GrugFar", "GrugFarWithin" },
}
