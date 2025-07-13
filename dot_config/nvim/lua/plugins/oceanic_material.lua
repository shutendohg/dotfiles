return {
    {
        "glepnir/oceanic-material",
        lazy = false,
        priority = 1000,
        config = function()
            vim.opt.background = "dark"
            vim.g.oceanic_material_background = "ocean"
            vim.g.oceanic_material_allow_italic = true
            vim.g.oceanic_material_allow_bold = true
            vim.g.oceanic_material_transparent_background = false
            vim.cmd.colorscheme("oceanic_material")
        end,
    },
}
