local tokyonight = require("tokyonight")

tokyonight.setup({
  transparent = true,
  on_highlights = function(hl, c)
    local prompt = "#2d3149"

    -- Telescope
    hl.TelescopeBorder = { bg = c.bg_highlight, fg = c.bg_highlight }
    hl.TelescopeNormal = { bg = c.bg_highlight, fg = c.fg_dark }
    hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
    hl.TelescopePromptNormal = { bg = prompt }
    hl.TelescopePromptPrefix = { bg = prompt, fg = c.purple }
    hl.TelescopePromptTitle = { bg = c.purple, fg = c.bg_dark }
    hl.TelescopePreviewTitle = { bg = c.cyan, fg = c.bg_dark }
    hl.TelescopePreviewNormal = { bg = c.bg_dark }
    hl.TelescopePreviewBorder = { bg = c.bg_dark }
    hl.TelescopeResultsTitle = { bg = c.red, fg = c.bg_dark }
    hl.TelescopeMatching = { fg = c.red }

    -- NvimTree
    -- hl.NvimTreeWindowPicker = { bg = colors.dark }
    -- hl.NvimTreeWinSeparator = { bg = colors.dark, fg = colors.dark }
    -- hl.NvimTreeCursorLine = { bg = colors.black }
    -- hl.NvimTreeRootFolder = { fg = colors.red, bold = true }
    -- hl.NvimTreeNormal = { bg = colors.dark }
    -- hl.NvimTreeNormalNC = { bg = colors.darker }
    -- hl.NvimTreeGitDirty = { fg = colors.red }
    -- hl.NvimTreeGitStaged = { fg = colors.green }
    -- hl.NvimTreeGitRenamed = { fg = colors.orange }
    -- hl.NvimTreeGitNew = { fg = colors.cyan }
    -- hl.NvimTreeGitDeleted = { fg = colors.pink }
    -- hl.NvimTreeLspDiagnosticsError = { fg = colors.red }
    -- hl.NvimTreeLspDiagnosticsWarning = { fg = colors.orange }
    -- hl.NvimTreeLspDiagnosticsInformation = { fg = colors.cyan }
    -- hl.NvimTreeLspDiagnosticsHint = { fg = colors.purple }
  end,
})

vim.cmd[[colorscheme tokyonight-storm]]
