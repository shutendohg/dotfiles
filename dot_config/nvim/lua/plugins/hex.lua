return {
	{
		"RaafatTurki/hex.nvim",
		lazy = false,
		config = function()
			local hex = require("hex")
			hex.setup()

			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					vim.schedule(function()
						if vim.bo.binary then
							hex.dump()
						end
					end)
				end,
			})
		end,
	},
}
