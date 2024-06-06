return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("lualine").setup({
            options = {
                theme = "catppuccin",
                component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
                section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
                ignore_focus = {
                    "TelescopePrompt",
                    "alpha",
                    "NvimTree",
                },
                globalstatus = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "diff", "diagnostics" },
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        file_status = true,
                        newfile_status = true,
                    },
                },
                lualine_x = { "searchcount" },
                lualine_y = { "filetype" },
                lualine_z = {
                    {
                        "tabs",
                        tab_max_length = 40,
                        max_length = vim.o.columns / 3,
                        mode = 0,
                        path = 0,
                        use_mod_colors = true,
                        symbols = {
                            modified = "·",
                        },
                    },
                },
            },
        })
    end,
}
