-- cache init.lua
vim.loader.enable()

-- basic config
vim.o.filetype = "plugin", "indent", "on"
vim.o.display = "lastline"
vim.o.number = true
vim.o.ruler = true
vim.o.list = true
-- >- means tab
vim.o.listchars = "tab:>-", "trail:*", "nbsp:+"

-- language
-- vim.api.nvim_exec ('language en_US', true)
-- spell checking
vim.opt.spell = true
vim.opt.spelllang = { "en_us", "cjk" }

-- syntax highlight on
vim.o.syntax = "enable"

-- Highlight setting of the rows
vim.o.cursorline = true

-- encoding
vim.o.encoding = "utf-8"
vim.scriptencoding = "utf-8"

-- visual for airline
vim.o.ambiwidth = "double"

-- Tab config
vim.o.tabstop = 4
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.smartindent = true

-- brackets config
vim.o.showmatch = true
vim.o.matchtime = 1

-- search config
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.api.nvim_set_keymap("n", "<Esc>", ":nohl<CR>", { noremap = true, silent = true })

-- key mapping
vim.opt.clipboard:append("unnamed")
vim.opt.clipboard:append("unnamedplus")
vim.o.undofile = false
vim.api.nvim_set_keymap("i", "jj", "<ESC>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "cw", ":close<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "L", ":bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "H", ":bprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "cb", ":bp|bd #<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "Y", "y$", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.keymap.set("n", "ss", ":split<Return><C-w>w")
vim.keymap.set("n", "sv", ":vsplit<Return><C-w>w")
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")

-- move the cursor to the previous/next line across the first/last character
vim.opt.whichwrap = "b,s,h,l,<,>,[,],~"

-- quick fix
vim.api.nvim_set_keymap("n", "<leader>qo", ":copen<CR>", { noremap = true, silent = true }) -- Open Quickfix
vim.api.nvim_set_keymap("n", "<leader>qc", ":cclose<CR>", { noremap = true, silent = true }) -- CLose Quickfix
vim.api.nvim_set_keymap("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true }) -- Jump to next entry
vim.api.nvim_set_keymap("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true }) -- Jump to previous entry
-- Set <CR> for Quickfix explicitly
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "<CR>", "<CR>", { buffer = true, noremap = true, silent = true })
	end,
})
vim.keymap.set(
	"n",
	"?",
	"<cmd>silent vimgrep//gj%|copen<cr>",
	{ desc = "Populate latest search result to quickfix list" }
)
-- use rg for external-grep
--
vim.opt.grepprg = table.concat({
	"rg",
	"--vimgrep",
	"--trim",
	"--hidden",
	[[--glob='!.git']],
	[[--glob='!*.lock']],
	[[--glob='!*-lock.json']],
	[[--glob='!*generated*']],
}, " ")
vim.opt.grepformat = "%f:%l:%c:%m"

-- ref: `:NewGrep` in `:help grep`
vim.api.nvim_create_user_command("Grep", function(arg)
	local grep_cmd = "silent grep! " .. (arg.bang and "--fixed-strings -- " or "") .. vim.fn.shellescape(arg.args, true)
	vim.cmd(grep_cmd)
	if vim.fn.getqflist({ size = true }).size > 0 then
		vim.cmd.copen()
	else
		vim.notify("no matches found", vim.log.levels.WARN)
		vim.cmd.cclose()
	end
end, { nargs = "+", bang = true, desc = "Enhounced grep" })

vim.keymap.set("n", "<space>/", ":Grep ", { desc = "Grep" })
vim.keymap.set("n", "<space>?", ":Grep <c-r><c-w>", { desc = "Grep current word" })

vim.diagnostic.config({
	virtual_text = false, -- virtual_text is off.
})

-- Setting to capitalize after typing ctr-u
vim.keymap.set("i", "<C-u>", function()
	local line = vim.fn.getline(".")
	local col = vim.fn.getpos(".")[3]
	local substring = line:sub(1, col - 1)
	local result = vim.fn.matchstr(substring, [[\v<(\k(<)@!)*$]]) or ""
	if result == "" then
		return ""
	end
	return "<C-w>" .. result:upper()
end, { expr = true, noremap = true })

for _, quote in ipairs({ '"', "'", "`" }) do
	vim.keymap.set({ "x", "o" }, "a" .. quote, "2i" .. quote)
end

-- setting repeating replacing
vim.keymap.set("n", "<leader>*", "*''cgn")
vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		-- Get a current window num
		local current_win = vim.api.nvim_get_current_win()
		-- Check all windows while lopping
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			-- Check not current
			if win ~= current_win then
				local buf = vim.api.nvim_win_get_buf(win)
				-- Finish the loop if the buftype has a normal buffer
				if vim.bo[buf].buftype == "" then
					return
				end
			end
		end
		-- Close all not currents because not current are special windows if it comes here.
		vim.cmd.only({ bang = true })
	end,
	desc = "Close all special buffers and quit Neovim",
})

require("lazy_nvim")
