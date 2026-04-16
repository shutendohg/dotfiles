return {
    "sirasagi62/toggle-cheatsheet.nvim",
    event = "VeryLazy",
    opts = true,

    config = function(_, persist)
        local tcs = require("toggle-cheatsheet").setup(persist)

        local cs1 = tcs.createCheatSheetFromSubmodeKeymap(tcs.conf({
            { "<leader>ff", "file search" },
            { "<leader>fg", "live grep" },
        }))

        vim.keymap.set("n", "<leader>q", function()
            tcs.toggle(cs1)
        end, { desc = "Cheatsheet 1" })
    end,
}
