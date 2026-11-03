return {
	{
		"lukas-reineke/indent-blankline.nvim",
		-- Load right after the first screen is drawn instead of while the first file is
		-- being opened: the scope (and rainbow-delimiters) parse the whole buffer with
		-- treesitter, which takes tens of ms for big grammars such as cpp.
		event = "VeryLazy",
		main = "ibl",
		dependencies = { "HiPhish/rainbow-delimiters.nvim" },
		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}

			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			require("ibl").setup({
				indent = { highlight = highlight, char = "|" },
				scope = {
					enabled = true,
					highlight = "Function",
				},
				exclude = {
					filetypes = {
						"help",
						"dashboard",
						"NvimTree",
						"Trouble",
						"lazy",
						"mason",
					},
				},
			})

			vim.g.rainbow_delimiters = {
				highlight = highlight,
			}

			-- rainbow-delimiters attaches on FileType, which already happened for the
			-- files opened before it was loaded (e.g. the ones given on the command line)
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "" then
					require("rainbow-delimiters").enable(buf)
				end
			end
		end,
	},
}
