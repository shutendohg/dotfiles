return {
    {
        "nvim-treesitter/nvim-treesitter",
        -- `main` (the rewrite) requires Nvim 0.12+, while the frozen `master` branch only
        -- supports Nvim 0.10/0.11 (and breaks e.g. Markdown on 0.12+).
        -- `main` is now the default branch, so without this a fresh install on Nvim 0.11
        -- (or an old clone on 0.12+) ends up with an API that `config.treesitter` can't use.
        branch = vim.fn.has("nvim-0.12") == 1 and "main" or "master",
        build = ":TSUpdate", -- Automatic update after installing
        lazy = false, -- nvim-treesitter does not support lazy-loading
        config = function()
            require("config.treesitter") -- Separating config file
        end,
    },
}
