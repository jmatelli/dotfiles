local ft = require("guard.filetype")

-- ft('go'):fmt('lsp')
--         :append('golines')
--         :lint('golangci')

ft("typescript,javascript,typescriptreact,javascriptreact"):fmt("prettierd")

ft("lua"):fmt("stylua"):lint("luacheck")

require("guard").setup({
  fmt_on_save = true,
  lsp_as_default_formatter = false,
})
