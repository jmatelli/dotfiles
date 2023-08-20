vim.g.indent_blankline_filetype_exclude = { "help", "packer", "telescope", "TelescopePrompt" }
vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile", "lazy", "alpha" }
vim.g.indent_blankline_show_trailing_blankline_indent = false

vim.opt.list = true
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup({
  show_end_of_line = true,
})
