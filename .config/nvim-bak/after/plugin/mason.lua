local mason = require("mason")
local settings = require("mason.settings")
local masonlsp = require("mason-lspconfig")

local servers = {
  "bashls",
  "tsserver",
  "html",
  "eslint",
  "lua_ls",
  "gopls",
  "tailwindcss",
  "jsonls",
  "yamlls",
  -- "stylelint_lsp",
}

settings.set({
  ui = {
    border = "rounded",
  }
})

mason.setup({
  ui = {
    icons = {
      package_installed = " ",
      package_pending = " ",
      package_uninstalled = "ﮊ "
    },
    keymaps = {
      toggle_package_expand = "<CR>",
      install_package = "i",
      update_package = "u",
      check_package_version = "c",
      update_all_packages = "U",
      check_outdated_packages = "C",
      uninstall_package = "X",
    },
  },
  max_concurrent_installers = 10,
})

masonlsp.setup({
  ensure_installed = servers
})
