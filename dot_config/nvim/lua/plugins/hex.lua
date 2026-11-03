return {
	{
		"RaafatTurki/hex.nvim",
		-- Loaded before the first file is read; lazy.nvim replays BufReadPre for the
		-- autocmds hex.nvim creates, so binary files are still detected.
		event = "BufReadPre",
		cmd = { "HexDump", "HexAssemble", "HexToggle" },
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
