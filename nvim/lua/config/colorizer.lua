local M = {}

local file = "config/colorizer.lua"

M.setup = function()
  local status_ok, colorizer = pcall(require, "colorizer")

  if not status_ok then
    vim.notify("Could not load colorizer in " .. file)
    return
  end

  colorizer.setup({
    "*",
    css = { css_fn = true, RRGGBBAA = true },
  }, {
    names = false,
  })

  vim.cmd "ColorizerAttachToBuffer"
end

return M
