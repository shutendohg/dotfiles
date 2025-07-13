-- plugins/mason-lspconfig.lua
return {
    "williamboman/mason-lspconfig.nvim",
    version = "^1.0.0",
    lazy = false,

    config = function()
        require("mason").setup()
        local servers = {
            "clangd", -- C / C++
            "bashls", -- Bash
            "pyright", -- Python
            "ts_ls", -- TypeScript  ※ ts_ls → tsserver が正式名
            "svelte", -- Svelte
            "lua_ls", -- Lua
            "marksman", -- Markdown
            "biome",
        }

        require("mason-lspconfig").setup({
            ensure_installed = servers,
            automatic_installation = true,
        })

        local function on_attach(client, bufnr)
            local maps = {
                { "K",  vim.lsp.buf.hover,          "Show hover info" },
                { "gd", vim.lsp.buf.definition,     "Go to definition" },
                { "gD", vim.lsp.buf.declaration,    "Go to declaration" },
                { "gb", "<C-t>",                    "Go back" },
                { "gf", vim.lsp.buf.format,         "Format code" },
                { "gr", vim.lsp.buf.references,     "List references" },
                { "gn", vim.lsp.buf.rename,         "Rename symbol" },
                { "gi", vim.lsp.buf.implementation, "Go to implementation" },
                { "ga", vim.lsp.buf.code_action,    "Code actions" },
                { "ge", vim.diagnostic.open_float,  "Show diagnostics" },
                { "g]", vim.diagnostic.goto_next,   "Next diagnostic" },
                { "g[", vim.diagnostic.goto_prev,   "Prev diagnostic" },
            }
            for _, m in ipairs(maps) do
                vim.keymap.set("n", m[1], m[2], { buffer = bufnr, silent = true, desc = m[3] })
            end

            -- Formatting before saving
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ timeout_ms = 1000 })
                end,
            })
        end

        local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

        require("mason-lspconfig").setup_handlers({
            function(server)
                local opts = {
                    on_attach = on_attach,
                    capabilities = capabilities,
                }

                -- clangd setup
                if server == "clangd" then
                    opts.cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--completion-style=detailed",
                        "--header-insertion=never",
                    }
                    opts.init_options = { clangdFileStatus = true }
                end

                require("lspconfig")[server].setup(opts)
            end,
        })

        -- disable virtual_text
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = false,
        })
    end,
}
