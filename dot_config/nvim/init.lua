if vim.fn.has("nvim-0.12") ~= 1 then
  error("This config requires Neovim >= 0.12 (uses native vim.pack). Current: " .. vim.version().major .. "." .. vim.version().minor)
end

require("config.options")
require("config.plugins")
require("config.lsp")
require("config.treesitter")
require("config.keymaps")
require("config.autocmds")
