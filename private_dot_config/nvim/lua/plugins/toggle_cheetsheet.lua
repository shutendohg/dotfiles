return {
    "sirasagi62/toggle-cheatsheet.nvim",
    event  = "VeryLazy",
    opts   = true,

    config = function(_, persist)
        local tcs = require("toggle-cheatsheet").setup(persist)

        local cs1 = tcs.createCheatSheetFromSubmodeKeymap(tcs.conf({
            { "gg", "Go to top" }, { "G", "Go to bottom" },
            { "%",  "Match bracket" },
        }))

        vim.keymap.set("n", "<leader>q", function() tcs.toggle(cs1) end, { desc = "Cheatsheet 1" })
        vim.keymap.set("n", "<leader>Q", function() tcs.toggle(cs2) end, { desc = "Cheatsheet 2" })
    end,
}
