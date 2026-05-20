vim.opt.clipboard = ""

vim.keymap.set("n", "<leader>y", function()
    require("vim.ui.clipboard.osc52").copy("+")(vim.fn.getreg('"', 1, true), vim.fn.getregtype('"'))
end, { desc = "Copy unnamed register via OSC52" })
