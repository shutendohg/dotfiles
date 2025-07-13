return {
    'yamatsum/nvim-cursorline',
    config = function()
        require('nvim-cursorline').setup({
            cursorline = {
                enable = true,  -- enable highlight of cursor
                timeout = 3,    -- Delay after cursor movement(milliseconds)
                number = false, -- Disable highlighting of the cursor line number
            },
            cursorword = {
                enable = true,             -- highlight the word under the cursor
                min_length = 3,            -- Minimum word length to highlight
                hl = { underline = true }, -- Highlight style (e.g., underline)
            },
        })
    end,
}
