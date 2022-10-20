--luacheck: globals vim

local M = {}
local colors = require("core.colors").dracula

M.highlights = {
  AlphaHeader = { fg = colors.currentLine }
}

return M
