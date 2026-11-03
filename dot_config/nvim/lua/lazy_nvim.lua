local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- lazy.nvim resets 'runtimepath' and guesses the directory with the parsers bundled with
-- Nvim (c, lua, markdown, vim, vimdoc, ...) from the path of the nvim binary:
-- <prefix>/lib/nvim or <prefix>/lib64/nvim. Distribution packages such as the Neovim PPA
-- install them under /usr/lib/<multiarch>/nvim instead, so they were lost, which broke
-- `:helptags` ('No parser for language "vimdoc"') and treesitter in the lua / markdown
-- ftplugins. Keep the directories that have them.
local parser_dirs = vim.tbl_map(vim.fs.dirname, vim.api.nvim_get_runtime_file("parser", true))

require('lazy').setup({
    spec = {
        { { import = "plugins" } }
    },
    performance = {
        rtp = {
            paths = parser_dirs,
        },
    },
})
