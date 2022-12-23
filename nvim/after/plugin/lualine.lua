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
  sections = {
    lualine_c = {
      {
        'filename',
        path = 3,
        shorting_target = 40,
        symbols = {
          modified = '[]',      -- Text to show when the file is modified.
          readonly = '[]',      -- Text to show when the file is non-modifiable or readonly.
          unnamed = '[]', -- Text to show for unnamed buffers.
          newfile = '[]',     -- Text to show for new created file before first writting
        }
      }
    },
  },
}
