local M = {}

local ensure_installed = { "typescript-language-server", "tailwindcss-language-server", "lua-language-server", "gopls", "eslint_d", "prettierd", "golangci-lint", "golines", "luacheck" }

M.init = function()
  local fn = vim.fn
  for i, package in ipairs(ensure_installed) do
    local install_path = fn.stdpath "data" .. "/mason/bin/" .. package
    if fn.empty(fn.glob(install_path)) > 0 then
      vim.cmd("MasonInstall " .. package)
      vim.notify("[Mason] ["..i.."/"..#ensure_installed.."] package "..package.." has been installed")
    end
  end
end

M.setup = function()
  local present, mason = pcall(require, "mason")

  if not present then
    return
  end

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

  M.init()
end

return M
