--   bg = "#222436",
--   bg_dark = "#1e2030",
--   bg_float = "#1e2030",
--   bg_highlight = "#2f334d",
--   bg_popup = "#1e2030",
--   bg_search = "#3e68d7",
--   bg_sidebar = "#1e2030",
--   bg_statusline = "#1e2030",
--   bg_visual = "#2d3f76",
--   black = "#1b1d2b",
--   blue = "#82aaff",
--   blue0 = "#3e68d7",
--   blue1 = "#65bcff",
--   blue2 = "#0db9d7",
--   blue5 = "#89ddff",
--   blue6 = "#b4f9f8",
--   blue7 = "#394b70",
--   border = "#1b1d2b",
--   border_highlight = "#589ed7",
--   comment = "#636da6",
--   cyan = "#86e1fc",
--   dark3 = "#545c7e",
--   dark5 = "#737aa2",
--   delta = {
--     add = "#305f6f",
--     delete = "#6b2e43"
--   },
--   diff = {
--     add = "#273849",
--     change = "#252a3f",
--     delete = "#3a273a",
--     text = "#394b70"
--   },
--   error = "#c53b53",
--   fg = "#c8d3f5",
--   fg_dark = "#828bb8",
--   fg_float = "#c8d3f5",
--   fg_gutter = "#3b4261",
--   fg_sidebar = "#828bb8",
--   git = {
--     add = "#b8db87",
--     change = "#7ca1f2",
--     delete = "#e26a75",
--     ignore = "#545c7e"
--   },
--   gitSigns = {
--     add = "#627259",
--     change = "#485a86",
--     delete = "#b55a67"
--   },
--   green = "#c3e88d",
--   green1 = "#4fd6be",
--   green2 = "#41a6b5",
--   hint = "#4fd6be",
--   info = "#0db9d7",
--   magenta = "#c099ff",
--   magenta2 = "#ff007c",
--   none = "NONE",
--   orange = "#ff966c",
--   purple = "#fca7ea",
--   red = "#ff757f",
--   red1 = "#c53b53",
--   teal = "#4fd6be",
--   terminal_black = "#444a73",
--   warning = "#ffc777",
--   yellow = "#ffc777"

return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
  enabled = false,
  config = function()
    require("tokyonight").setup({
      style = "storm",
      transparent = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
      on_highlights = function(highlight, color)
        local prompt = "#1d2139"

        -- Telescope
        highlight.TelescopeBorder = { bg = prompt, fg = prompt }
        highlight.TelescopeNormal = { bg = prompt, fg = color.fg }
        highlight.TelescopePromptBorder = { bg = color.black, fg = color.black }
        highlight.TelescopePromptNormal = { bg = color.black }
        highlight.TelescopePromptPrefix = { bg = color.black, fg = color.purple }
        highlight.TelescopePromptTitle = { bg = color.purple, fg = color.bg_dark }
        highlight.TelescopePreviewTitle = { bg = color.cyan, fg = color.bg_dark }
        highlight.TelescopePreviewNormal = { bg = color.bg_dark }
        highlight.TelescopePreviewBorder = { bg = color.bg_dark }
        highlight.TelescopeResultsTitle = { bg = color.red, fg = color.bg_dark }
        highlight.TelescopeMatching = { fg = color.red }

        -- NvimTree
        highlight.NvimTreeNormal = { bg = 'NONE' }
        highlight.NvimTreeRootFolder = { fg = color.red, bold = true }
        highlight.NvimTreeGitDirty = { fg = color.red }
        highlight.NvimTreeGitStaged = { fg = color.green }
        highlight.NvimTreeGitRenamed = { fg = color.orange }
        highlight.NvimTreeGitNew = { fg = color.cyan }
        highlight.NvimTreeGitDeleted = { fg = color.pink }
        highlight.NvimTreeLspDiagnosticsError = { fg = color.red }
        highlight.NvimTreeLspDiagnosticsWarning = { fg = color.orange }
        highlight.NvimTreeLspDiagnosticsInformation = { fg = color.cyan }
        highlight.NvimTreeLspDiagnosticsHint = { fg = color.purple }

        highlight["@constructor.tsx"] = { fg = color.red1 }
        highlight["@tag.tsx"] = { fg = color.red }
        highlight["@tag.delimiter.tsx"] = { fg = color.magenta2 }
      end,
    })

    -- vim.cmd([[colorscheme tokyonight-moon]])
  end,
}
