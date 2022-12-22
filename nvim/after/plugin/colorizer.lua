local colorizer = require("colorizer")

colorizer.setup({
  "*",
  css = { css_fn = true, RRGGBBAA = true },
}, {
  names = false,
})

vim.cmd "ColorizerAttachToBuffer"
