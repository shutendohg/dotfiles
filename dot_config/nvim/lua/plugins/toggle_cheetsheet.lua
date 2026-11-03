return {
    "sirasagi62/toggle-cheatsheet.nvim",
    event = "VeryLazy",
    opts = true,

    config = function(_, persist)
        local tcs = require("toggle-cheatsheet").setup(persist)

        local mappings = {
            { "<leader>ff", "file search" },
            { "<leader>fg", "live grep" },
        }

        local toggle
        if tcs.create then
            -- v2 API: `conf()` / `createCheatSheetFromSubmodeKeymap()` were removed
            local cs1 = tcs.create({
                id = "cheatsheet1",
                mappings = vim.tbl_map(function(m)
                    return { key = m[1], desc = m[2] }
                end, mappings),
            })
            toggle = function()
                cs1:toggle()
            end
        else
            -- legacy API (older versions of the plugin)
            local cs1 = tcs.createCheatSheetFromSubmodeKeymap(tcs.conf(mappings))
            toggle = function()
                tcs.toggle(cs1)
            end
        end

        vim.keymap.set("n", "<leader>q", toggle, { desc = "Cheatsheet 1" })
    end,
}
