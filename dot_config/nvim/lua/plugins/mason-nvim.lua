return {
    "williamboman/mason.nvim",
    version = "^1.10.0",
    build   = ":MasonUpdate", -- Update index every time
    lazy    = false,
    config  = function()
        require("mason").setup()
    end,
}
