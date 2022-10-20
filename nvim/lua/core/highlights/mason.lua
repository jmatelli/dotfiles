--luacheck: globals vim

local M  = {}
local colors = require("core.colors").dracula

M.highlights = {
  MasonHeader = { fg = colors.black, bg = colors.pink },
  MasonHeaderSecondary = { link = "MasonHighlightBlock" },

  MasonHighlight = { fg = colors.yellow },
  MasonHighlightBlock = { fg = colors.black, bg = colors.pink },
  MasonHighlightBlockBold = { link = "MasonHighlightBlock" },
  MasonMuted = { fg = colors.currentLine },
  MasonMutedBlock = { fg = colors.currentLine, bg = colors.black },
}

return M
