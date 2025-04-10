return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                transparent_background = true,
                flavor = "mocha",
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    mason = true,
                    native_lsp = { enable = true },
                    neotree = true,
                    telescope = true,
                    treesitter = true,
                    treesitter_context = true,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                },
                custom_highlights = function(colors)
                    return {
                        ["@constructor.tsx"] = { fg = colors.red },
                        ["@tag.tsx"] = { fg = colors.red },
                        ["@tag"] = { fg = colors.pink },
                        ["@tag.delimiter.tsx"] = { fg = colors.mauve },
                        ["@tag.delimiter"] = { fg = colors.mauve },
                        LineNr = { fg = colors.overlay1 },
                        CursorLineNr = { fg = colors.teal, bold = true },
                    }
                end,
            })
            -- vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                transparent = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                },
                on_highlights = function(highlights, colors)
                    highlights["@constructor.tsx"] = { fg = colors.red1 }
                    highlights["@tag.tsx"] = { fg = colors.red }
                    highlights["@tag"] = { fg = colors.red1 }
                    highlights["@tag.delimiter.tsx"] = { fg = colors.magenta2 }
                    highlights["@tag.delimiter"] = { fg = colors.magenta2 }
                    highlights.LineNr = { fg = colors.teal }
                    highlights.CursorLineNr = { fg = colors.teal, bold = true }
                end,
            })
        end,
    },
    {
        "navarasu/onedark.nvim",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        opts = {
            style = "cool",
            transparent = true,
        },
    },
    {
        "horanmustaplot/xcarbon.nvim",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
    },
    {
        "shaunsingh/nord.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.nord_disable_background = true
            vim.g.nord_bold = false
            vim.g.nord_border = true
            vim.g.nord_contrast = true

            require("headlines").setup({
                markdown = {
                    headline_highlights = {
                        "Headline1",
                        "Headline2",
                        "Headline3",
                        "Headline4",
                        "Headline5",
                        "Headline6",
                    },
                    codeblock_highlight = "CodeBlock",
                    dash_highlight = "Dash",
                    quote_highlight = "Quote",
                },
            })
        end,
        init = function()
            vim.cmd.colorscheme("nord")
        end,
    },
    {
        "slugbyte/lackluster.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            local lackluster = require("lackluster")
            lackluster.setup({
                tweak_syntax = {
                    comment = lackluster.color.gray6,
                },
                tweak_background = {
                    normal = 'none',    -- main background
                    telescope = 'none', -- telescope
                    menu = 'none',      -- nvim_cmp, wildmenu ... (bad idea to transparent)
                    popup = 'none',     -- lazy, mason, whichkey ... (bad idea to transparent)
                },
            })
            -- require('nvim-web-devicons').setup({
            --     color_icons = false,
            --     override = {
            --         ["default_icon"] = {
            --             color = lackluster.color.gray4,
            --             name = "Default",
            --         }
            --     }
            -- })
        end,
        init = function()
            -- vim.cmd.colorscheme("lackluster")
            -- vim.cmd.colorscheme("lackluster-dark")
            -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
            -- vim.cmd.colorscheme("lackluster-mint")
            -- vim.cmd.colorscheme("lackluster-night")
        end,
    },
}
