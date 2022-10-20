--luacheck: globals vim

local M = {}
local colors = require("core.colors").dracula

-- colors are taken from Dracula theme page: https://draculatheme.com/contribute
-- the following highlight settings are heavily inspired by NvChad: https://github.com/NvChad/base46/blob/master/lua/base46/integrations/telescope.lua
M.highlights = {
  TelescopeBorder = { bg = colors.black, fg = colors.black },
  TelescopePromptBorder = { bg = colors.currentLine, fg = colors.currentLine },
  TelescopePromptNormal = { bg = colors.currentLine, fg = colors.foreground },
  TelescopePromptPrefix = { bg = colors.currentLine, fg = colors.pink },
  TelescopeNormal = { bg = colors.black },
  TelescopePreviewTitle = { fg = colors.black, bg = colors.cyan },
  TelescopePreviewBorder = { bg = colors.dark },
  TelescopePreviewNormal = { bg = colors.dark },
  TelescopePromptTitle = { fg = colors.black, bg = colors.pink },
  TelescopeResultsTitle = { fg = colors.black, bg = colors.black },
  TelescopeSelection = { fg = colors.foreground, bg = colors.dark },
  TelescopeResultsDiffAdd = { fg = colors.green },
  TelescopeResultsDiffChange = { fg = colors.yellow },
  TelescopeResultsDiffDelete = { fg = colors.red },
  TelescopeMatching = { fg = colors.red },
}

return M
