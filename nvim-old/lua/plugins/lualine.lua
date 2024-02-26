return {
 "nvim-lualine/lualine.nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.statusline = 0
    end
  end,
  config = function()
    local lualine_require = require('lualine_require')
    lualine_require.require = require

    vim.o.laststatus = vim.g.lualine_laststatus

    require('lualine').setup({
      options = {
        -- theme = "tokyonight",
        theme = "catppuccin",
        component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
        section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },

        disabled_filetypes = {
          statusline = { "alpha" },
        },

        ignore_focus = {
          "TelescopePrompt", "alpha", "NvimTree",
        },

        globalstatus = true,
      },
      sections = {
        lualine_a = {
          {
            'tabs',
            tab_max_length = 40,
            max_length = vim.o.columns / 3,
            mode = 0,
            path = 0,
            use_mod_colors = true,
            show_modified_status = true,
            symbols = {
              modified = '·'
            },
          },
        },
        lualine_b = { 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            path = 3,
            shorting_target = 40,
            symbols = {
              modified = '[]', -- Text to show when the file is modified.
              readonly = '[]', -- Text to show when the file is non-modifiable or readonly.
              unnamed = '[]',  -- Text to show for unnamed buffers.
              newfile = '[]',  -- Text to show for new created file before first writting
            }
          }
        },
        lualine_x = { 'filetype', 'branch' },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
