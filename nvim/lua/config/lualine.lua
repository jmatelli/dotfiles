local M = {}

function M.setup()
  require("lualine").setup {
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
