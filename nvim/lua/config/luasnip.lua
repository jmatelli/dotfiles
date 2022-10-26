local M = {}

local file = "config/luasnip.lua"

M.setup = function()
  local status_ok, luasnip = pcall(require, "luasnip")
  local status_ok_loaders, loaders = pcall(require, "luasnip.loaders.from_vscode")

  if not status_ok then
    return vim.notify("Could not load luasnip in " .. file)
  end

  if not status_ok_loaders then
    return vim.notify("Could not load luasnip.loaders.from_vscode in " .. file)
  end

  local options = {
    history = true,
    updateevents = "TextChanged,TextChangedI",
  }

  luasnip.config.set_config(options)
  loaders.lazy_load { paths = vim.g.luasnippets_path or "" }
  loaders.lazy_load()

  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      if
        luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
        and not luasnip.session.jump_active
      then
        luasnip.unlink_current()
      end
    end,
  })
end

return M
