local osc52 = require("vim.ui.clipboard.osc52")

local function paste_from_register(reg)
	return function()
		return {
			vim.fn.split(vim.fn.getreg(reg), "\n"),
			vim.fn.getregtype(reg),
		}
	end
end

vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = osc52.copy("+"),
		["*"] = osc52.copy("*"),
	},
	paste = {
		["+"] = paste_from_register("+"),
		["*"] = paste_from_register("*"),
	},
}

vim.opt.clipboard = "unnamedplus"
