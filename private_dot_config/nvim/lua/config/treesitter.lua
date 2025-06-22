require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "c", "cpp", "lua", "python", "javascript", "typescript", "json", "yaml", "toml", "bash", "markdown"
    },
    sync_install = false, -- If set true, wait time happens
    auto_install = true,  -- If uninstall langs are used, installed automatically

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false, -- avoid confliction existing vim highlight
    },

    indent = {
        enable = true,
    },

    matchup = {
        enable = true, -- display matching pairs
    },
})
