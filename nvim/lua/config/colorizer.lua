local M = {}

M.setup = function()
  local present, colorizer = pcall(require, "colorizer")

  if not present then
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
