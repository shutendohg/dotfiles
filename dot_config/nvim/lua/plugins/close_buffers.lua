return {
	{
		"kazhala/close-buffers.nvim",
		cmd = { "BDelete", "Bwipeout" },
		config = function()
			require("close_buffers").setup({
				preserve_window_layout = { "this", "nameless" },
			})

			local map = vim.api.nvim_set_keymap
			local opts = { noremap = true, silent = true }

			-- Close all unchanged buffers
			map("n", "<leader>bo", "<cmd>BDelete all<CR>", opts)

			-- Close all buffers except a current buffer
			map("n", "<leader>bc", "<cmd>BDelete other<CR>", opts)

			-- Close all hidden buffers
			map("n", "<leader>bh", "<cmd>BDelete hidden<CR>", opts)

			-- Close a specified buffer
			map("n", "<leader>bs", "<cmd>BDelete! this<CR>", opts)
		end,
	},
}
