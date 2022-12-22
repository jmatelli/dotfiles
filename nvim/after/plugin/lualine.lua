local lualine = require("lualine")

lualine.setup {
  options = {
    theme = "tokyonight",
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
