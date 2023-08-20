local tokyonight = require("tokyonight")

-- local colors = {
--   bg = "#24283b",
--   bg_dark = "#1f2335",
--   bg_float = "#1f2335",
--   bg_highlight = "#292e42",
--   bg_popup = "#1f2335",
--   bg_search = "#3d59a1",
--   bg_sidebar = "#1f2335",
--   bg_statusline = "#1f2335",
--   bg_visual = "#2e3c64",
--   black = "#1d202f",
--   blue = "#7aa2f7",
--   blue0 = "#3d59a1",
--   blue1 = "#2ac3de",
--   blue2 = "#0db9d7",
--   blue5 = "#89ddff",
--   blue6 = "#b4f9f8",
--   blue7 = "#394b70",
--   border = "#1d202f",
--   border_highlight = "#29a4bd",
--   comment = "#565f89",
--   cyan = "#7dcfff",
--   dark3 = "#545c7e",
--   dark5 = "#737aa2",
--   delta = {
--     add = "#316172",
--     delete = "#763842"
--   },
--   diff = {
--     add = "#283b4d",
--     change = "#272d43",
--     delete = "#3f2d3d",
--     text = "#394b70"
--   },
--   error = "#db4b4b",
--   fg = "#c0caf5",
--   fg_dark = "#a9b1d6",
--   fg_float = "#c0caf5",
--   fg_gutter = "#3b4261",
--   fg_sidebar = "#a9b1d6",
--   git = {
--     add = "#449dab",
--     change = "#6183bb",
--     delete = "#914c54",
--     ignore = "#545c7e"
--   },
--   gitSigns = {
--     add = "#266d6a",
--     change = "#536c9e",
--     delete = "#b2555b"
--   },
--   green = "#9ece6a",
--   green1 = "#73daca",
--   green2 = "#41a6b5",
--   hint = "#1abc9c",
--   info = "#0db9d7",
--   magenta = "#bb9af7",
--   magenta2 = "#ff007c",
--   none = "NONE",
--   orange = "#ff9e64",
--   purple = "#9d7cd8",
--   red = "#f7768e",
--   red1 = "#db4b4b",
--   teal = "#1abc9c",
--   terminal_black = "#414868",
--   warning = "#e0af68",
--   yellow = "#e0af68"
-- }

tokyonight.setup({
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
  },
  on_highlights = function(highlight, color)
    local prompt = "#2d3149"

    -- Telescope
    highlight.TelescopeBorder = { bg = color.bg_highlight, fg = color.bg_highlight }
    highlight.TelescopeNormal = { bg = color.bg_highlight, fg = color.fg_dark }
    highlight.TelescopePromptBorder = { bg = prompt, fg = prompt }
    highlight.TelescopePromptNormal = { bg = prompt }
    highlight.TelescopePromptPrefix = { bg = prompt, fg = color.purple }
    highlight.TelescopePromptTitle = { bg = color.purple, fg = color.bg_dark }
    highlight.TelescopePreviewTitle = { bg = color.cyan, fg = color.bg_dark }
    highlight.TelescopePreviewNormal = { bg = color.bg_dark }
    highlight.TelescopePreviewBorder = { bg = color.bg_dark }
    highlight.TelescopeResultsTitle = { bg = color.red, fg = color.bg_dark }
    highlight.TelescopeMatching = { fg = color.red }

    -- NvimTree
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

vim.cmd[[colorscheme tokyonight-storm]]
