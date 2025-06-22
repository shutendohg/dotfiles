return {
	{
		"monaqa/dial.nvim",
		keys = { { "<C-a>", mode = "n" }, { "<C-x>", mode = "n" } },
		config = function()
			local dial = require("dial.map")
			local augend = require("dial.augend")

			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal, -- decimal increment
					augend.integer.alias.hex, -- hex increment
					augend.date.alias["%Y/%m/%d"], -- date increment
					augend.constant.alias.bool, -- boolean switching
				},
			})
			vim.keymap.set("n", "<C-a>", dial.inc_normal(), { noremap = true, silent = true })
			vim.keymap.set("n", "<C-x>", dial.dec_normal(), { noremap = true, silent = true })
			vim.keymap.set("v", "<C-a>", dial.inc_visual(), { noremap = true, silent = true })
			vim.keymap.set("v", "<C-x>", dial.dec_visual(), { noremap = true, silent = true })
			vim.keymap.set("v", "g<C-a>", dial.inc_gvisual(), { noremap = true, silent = true })
			vim.keymap.set("v", "g<C-x>", dial.dec_gvisual(), { noremap = true, silent = true })
		end,
	},
}
