local function setup_osc52()
    local osc52 = require("osc52")

    vim.keymap.set("n", "<leader>c", osc52.copy_operator, { expr = true })
    vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
    vim.keymap.set("v", "<leader>c", osc52.copy_visual)
    osc52.setup({
        max_length = 0, -- Unlimited
        silent = false, -- Not display successful messages setting true
    })
end

return {
    "ojroques/nvim-osc52",
    config = setup_osc52,
}
