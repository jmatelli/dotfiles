return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    vim.g.indent_blankline_show_trailing_blankline_indent = false

    vim.opt.list = true
    vim.opt.listchars:append("eol:↴")

    require("ibl").setup({
      scope = {
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = { "help", "packer", "telescope", "TelescopePrompt", "neo-tree", "Trouble", "trouble" },
        buftypes = { "terminal", "nofile", "lazy", "alpha", "mason" },
      }
    })
  end
}
