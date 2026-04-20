return {
	{
		"kazhala/close-buffers.nvim",
		cmd = { "BDelete", "Bwipeout" },
		keys = {
			{ "<leader>bo", "<cmd>BDelete all<CR>", desc = "Delete unchanged buffers" },
			{ "<leader>bc", "<cmd>BDelete other<CR>", desc = "Delete other buffers" },
			{ "<leader>bh", "<cmd>BDelete hidden<CR>", desc = "Delete hidden buffers" },
			{ "<leader>bs", "<cmd>BDelete! this<CR>", desc = "Delete current buffer" },
		},
		config = function()
			require("close_buffers").setup({
				preserve_window_layout = { "this", "nameless" },
			})
		end,
	},
}
