return {
	"andymass/vim-matchup",
	event = "VeryLazy",
	config = function()
		-- Pop-up display of off-screen pairs (Neovim floating window version)
		vim.g.matchup_matchparen_offscreen = { method = "popup" }
		-- highlighting matches a bit more sparingly
		vim.g.matchup_matchparen_hi_surround_always = 1
		vim.g.matchup_matchparen_deferred = 1 -- Asynchronous and lightweight
	end,
}
