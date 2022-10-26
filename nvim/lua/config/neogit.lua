local M = {}

local file = "config/neogit.lua"

function M.setup()
  local status_ok, neogit = pcall(require, "neogit")

  if not status_ok then
    return vim.notify("could not load neogit in " .. file)
  end

  neogit.setup {}
end

return M
