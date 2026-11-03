return {
    {
        "j-hui/fidget.nvim",
        -- Only shows LSP progress, so it is not needed before a language server attaches
        event = "LspAttach",
        opts = {
            -- optional config
            notification = {
                window = {
                    winblend = 0, -- transparency of the windwo(zero is not transparent)
                },
            },
        },
    },
}
