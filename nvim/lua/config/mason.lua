local M = {}

local file = "config/mason.lua"

local ensure_installed = {
  -- formatters
  "prettierd",
  "golines",

  -- linters
  "eslint_d",
  "luacheck",
}
local ensure_installed_lspconfig = {
  -- language servers
  "cssls",
  "cssmodules_ls",
  "diagnosticls",
  "dockerls",
  "eslint",
  "golangci_lint_ls",
  "gopls",
  "html",
  "jsonls",
  "stylelint_lsp",
  "sumneko_lua",
  "tailwindcss",
  "tsserver",
}

M.init = function()
  local fn = vim.fn
  for i, package in ipairs(ensure_installed) do
    local install_path = fn.stdpath "data" .. "/mason/bin/" .. package
    if fn.empty(fn.glob(install_path)) > 0 then
      vim.cmd("MasonInstall " .. package)
      vim.notify("[Mason] [" .. i .. "/" .. #ensure_installed .. "] package " .. package .. " has been installed")
    end
  end
end

M.setup = function()
  local status_ok_utils, utils = pcall(require, "core.utils")

  if not status_ok_utils then
    return vim.notify("Could not load core.utils in " .. file)
  end

  utils.load_highlights "mason"

  local status_ok_mason, mason = pcall(require, "mason")
  local status_ok_mason_lspconfig, lspconfig = pcall(require, "mason-lspconfig")

  if not status_ok_mason then
    return vim.notify("Could not load mason in " .. file)
  end

  if not status_ok_mason_lspconfig then
    return vim.notify("Could not load mason-lspconfig in " .. file)
  end

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

  lspconfig.setup {
    ensure_installed = ensure_installed_lspconfig,
  }

  M.init()
end

return M
