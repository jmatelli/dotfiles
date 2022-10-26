local colors = require("core.colors").dracula

return {
  CmpBorder = { fg = colors.currentLine },
  CmpDocBorder = { fg = colors.currentLine },
  CmpDocNormal = { bg = colors.currentLine },

  CmpItemKindFunction = { fg = colors.cyan },
  CmpItemKindMethod = { fg = colors.cyan },

  CmpItemKindVariable = { fg = colors.green },
  CmpItemKindText = { fg = colors.green },
  CmpItemKindInterface = { fg = colors.green },
  CmpItemKindConstant = { fg = colors.green },

  CmpItemKindProperty = { fg = colors.comment },
  CmpItemKindKeyword = { fg = colors.comment },
  CmpItemKindUnit = { fg = colors.comment },

  CmpItemKindType = { fg = colors.pink },
  CmpItemKindTypeParameter = { fg = colors.pink },

  CmpItemKindSnippet = { fg = colors.red },

  CmpItemAbbrDeprecated = { fg = colors.foreground },

  CmpItemAbbrMatch = { fg = colors.red },
  CmpItemAbbrMatchFuzzy = { fg = colors.red },
  -- TODO: complete the colors accordingly
}
