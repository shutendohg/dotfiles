return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local builtin = require("telescope.builtin")

		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files({
				hidden = true,
				find_command = {
					"rg",
					"--files",
					"--hidden",
					"-g",
					"!.git",
				},
			})
		end)

		vim.keymap.set("n", "<leader>fg", function()
			builtin.live_grep({
				additional_args = function()
					return {
						"--hidden",
						"--glob",
						"!.git/*",
					}
				end,
			})
		end)

		vim.keymap.set("n", "<leader>fh", builtin.help_tags)
		vim.keymap.set("n", "<leader>gb", builtin.git_branches)
		vim.keymap.set("n", "<leader>bf", builtin.buffers, { noremap = true })
	end,
}
