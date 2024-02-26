local ft = require("guard.filetype")

-- ft('go'):fmt('lsp')
--         :append('golines')
--         :lint('golangci')

ft("typescript,javascript,typescriptreact,javascriptreact"):fmt("prettier")

ft("lua"):fmt("lsp"):append("stylua"):lint("luacheck")

ft("kotlin"):fmt("ktlint"):lint("ktlint")

require("guard").setup({
  fmt_on_save = true,
  lsp_as_default_formatter = false,
})
