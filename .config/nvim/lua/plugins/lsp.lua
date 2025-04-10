return {
  "neovim/nvim-lspconfig",
  opts = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "<S-d>", vim.diagnostic.goto_next }
    keys[#keys + 1] = { "<S-u>", vim.diagnostic.goto_prev }
  end,
}
