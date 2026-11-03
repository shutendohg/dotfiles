return {
    "williamboman/mason.nvim",
    version = "^1.10.0",
    build = ":MasonUpdate", -- Update index every time
    -- Loaded right after startup as a dependency of mason-lspconfig / none-ls,
    -- or earlier when one of its commands is used.
    cmd = { "Mason", "MasonUpdate", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    config = function()
        require("mason").setup()
    end,
}
