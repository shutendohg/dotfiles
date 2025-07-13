-- plugins/none-ls.lua
return {
	"nvimtools/none-ls.nvim",
	commit = "6be90f8cf37d7f50a89b7229412f6184b16f1b28", -- set a specified commit
	dependencies = {
		"williamboman/mason.nvim",
		"jay-babu/mason-null-ls.nvim",
		{
			"nvimtools/none-ls-extras.nvim",
			lazy = false,
		},
	},
	config = function()
		require("mason-null-ls").setup({
			ensure_installed = {
				-- formatters
				"clang-format",
				"shfmt",
				"stylua",
				"ruff_format",
				"prettier",
				-- linters
				"selene",
				"ruff",
				"markdownlint",
			},
			automatic_installation = true,
			automatic_setup = false, -- disable automatic_setup
		})

		local null_ls = require("null-ls")
		local extras = {
			ruff_format = require("none-ls.formatting.ruff"),
			ruff_diag = require("none-ls.diagnostics.ruff"),
		}
		null_ls.setup({
			sources = {
				-- ---- Python ----------------------------------------
				extras.ruff_format,
				extras.ruff_diag,
				-- ---- C/C++ -----------------------------------------
				null_ls.builtins.formatting.clang_format,
				-- ---- Shell -----------------------------------------
				null_ls.builtins.formatting.shfmt,
				-- ---- Lua / Markdown --------------------------------
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.diagnostics.selene,
				null_ls.builtins.diagnostics.markdownlint,
				-- (optional) If users want to use Prettier only for  Markdown/JS
				-- null_ls.builtins.formatting.prettier.with({ filetypes = { "markdown", "javascript", "typescript" } }),
			},
			debounce = 150,
			update_in_insert = false,
			on_attach = function(_, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({
							bufnr = bufnr,
							async = false,
							timeout_ms = 1000,
							filter = function(client)
								return client.name == "null-ls"
							end,
						})
					end,
				})
			end,
		})
	end,
}
