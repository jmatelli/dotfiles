--luacheck: globals vim

local M = {}
local colors = require("core.colors").dracula

M.highlights = {
  NvimTreeWindowPicker = { bg = colors.dark },
  NvimTreeWinSeparator = { bg = colors.dark, fg = colors.dark },
  NvimTreeCursorLine = { bg = colors.black },
  NvimTreeRootFolder = { fg = colors.red, bold = true },
  NvimTreeNormal = { bg = colors.dark },
  NvimTreeNormalNC = { bg = colors.darker },

  -- Git colors
  NvimTreeGitDirty = { fg = colors.red },
  NvimTreeGitStaged = { fg = colors.green },
  NvimTreeGitRenamed = { fg = colors.orange },
  NvimTreeGitNew = { fg = colors.cyan },
  NvimTreeGitDeleted = { fg = colors.pink },

  -- Diagnostic colors
  NvimTreeLspDiagnosticsError = { fg = colors.red },
  NvimTreeLspDiagnosticsWarning = { fg = colors.orange },
  NvimTreeLspDiagnosticsInformation = { fg = colors.cyan },
  NvimTreeLspDiagnosticsHint = { fg = colors.purple },
}

return M
