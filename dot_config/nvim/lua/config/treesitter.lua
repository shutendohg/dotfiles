local ensure_installed = {
	"c",
	"cpp",
	"lua",
	"python",
	"javascript",
	"typescript",
	"json",
	"yaml",
	"toml",
	"bash",
	"markdown",
}

if vim.fn.has("nvim-0.12") == 0 then
	-- nvim-treesitter `master` branch (Nvim 0.10 / 0.11)
	require("nvim-treesitter.configs").setup({
		ensure_installed = ensure_installed,
		sync_install = false, -- If set true, wait time happens
		auto_install = true, -- If uninstall langs are used, installed automatically

		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false, -- avoid confliction existing vim highlight
		},

		indent = {
			enable = true,
		},
	})
	return
end

-- nvim-treesitter `main` branch (Nvim 0.12+)
-- Highlighting is built into Nvim (`vim.treesitter.start()`, which also turns off regex
-- syntax highlighting); the plugin provides the parsers, the queries and the indentexpr.
local ts = require("nvim-treesitter")

local function has_query(lang, name)
	return #vim.treesitter.query.get_files(lang, name) > 0
end

-- Same conditions as the old `highlight` / `indent` modules: a parser plus the query.
local function attach(buf, lang)
	local ok, loaded = pcall(vim.treesitter.language.add, lang)
	if not (ok and loaded and has_query(lang, "highlights")) then
		return false
	end
	if not pcall(vim.treesitter.start, buf, lang) then
		return false
	end
	if has_query(lang, "indents") then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
	return true
end

-- The `main` branch builds parsers with the tree-sitter CLI
local function install(langs)
	if vim.fn.executable("tree-sitter") == 0 then
		vim.notify_once("nvim-treesitter: `tree-sitter` CLI not found, cannot install parsers", vim.log.levels.WARN)
		return nil
	end
	return ts.install(langs)
end

local available -- languages nvim-treesitter can install (computed on first use)
local function is_available(lang)
	if not available then
		available = {}
		for _, l in ipairs(ts.get_available()) do
			available[l] = true
		end
	end
	return available[lang] == true
end

local function setup_buf(buf, ft)
	local lang = vim.treesitter.language.get_lang(ft)
	if not lang or attach(buf, lang) then
		return
	end
	-- only for file buffers (not NvimTree, Telescope prompts, ...)
	if vim.bo[buf].buftype ~= "" then
		return
	end
	if not is_available(lang) or vim.list_contains(ts.get_installed(), lang) then
		return
	end
	-- auto_install: install the missing parser in the background, then attach
	local task = install(lang)
	if task then
		task:await(function(err, ok)
			if err or not ok then
				return
			end
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == ft then
					attach(buf, lang)
				end
			end)
		end)
	end
end

local group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })

-- Buffers whose filetype was set while Nvim was starting (files given on the command line).
-- Starting treesitter compiles the highlight/injection queries of the language, which takes
-- tens to hundreds of ms for big grammars (e.g. ~300ms for cpp, ~100ms for typescript).
-- So the first screen is drawn with the regular syntax highlighting and treesitter is
-- started once the rest of the UI (statusline, LSP, ... = VeryLazy plugins) is loaded.
-- Files opened later are handled immediately as usual.
local pending = {}

-- highlight / indent (+ auto_install)
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(ev)
		if vim.v.vim_did_enter == 1 or #vim.api.nvim_list_uis() == 0 then
			setup_buf(ev.buf, ev.match)
			return
		end
		if #pending == 0 then
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "VeryLazy",
				once = true,
				callback = function()
					vim.schedule(function()
						for _, p in ipairs(pending) do
							if vim.api.nvim_buf_is_valid(p.buf) and vim.bo[p.buf].filetype == p.ft then
								setup_buf(p.buf, p.ft)
							end
						end
						pending = {}
					end)
				end,
			})
		end
		pending[#pending + 1] = { buf = ev.buf, ft = ev.match }
	end,
})

-- ensure_installed: checked after startup so that it never delays the first screen
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "VeryLazy",
	once = true,
	callback = function()
		local installed = ts.get_installed()
		local missing = vim.tbl_filter(function(lang)
			return not vim.list_contains(installed, lang)
		end, ensure_installed)
		if #missing > 0 then
			install(missing)
		end
	end,
})
