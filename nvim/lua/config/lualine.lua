local M = {}

local file = "config/lualine.lua"

function M.setup()
  local status_ok, lualine = pcall(require, "lualine")

  if not status_ok then
    return vim.notify("Could not load lualine in " .. file)
  end

  lualine.setup {
    options = {
      theme = "dracula",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },

      disabled_filetypes = {
        statusline = { "alpha" },
      },

      ignore_focus = {
        "TelescopePrompt", "alpha", "NvimTree",
      },

      globalstatus = true,
    },
  }
end

return M
