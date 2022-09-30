local M = {}

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
  "html",
  "cssls",
  "tsserver",
  "tailwindcss",
  "sumneko_lua",
  "gopls",
  "golangci_lint_ls",
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
  local present, mason = pcall(require, "mason")
  if not present then return end

  local present2, lspconfig = pcall(require, "mason-lspconfig")
  if not present2 then return end

  require("core.utils").load_highlights "mason"
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
