local colors = require("core.colors").dracula

vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

return {
  DiagnosticError = { fg = colors.red },
  DiagnosticWarn = { fg = colors.orange },
  DiagnosticInfo = { fg = colors.blue },
  DiagnosticHint = { fg = colors.purple },
}
