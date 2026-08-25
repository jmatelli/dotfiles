return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "rose-pine",
        component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
        section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
        ignore_focus = {
          "TelescopePrompt",
          "alpha",
          "NvimTree",
        },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "diff",
          {
            "diagnostics",
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = " ",
            },
          },
        },
        lualine_c = {
          {
            "filename",
            path = 1,
            file_status = true,
            newfile_status = true,
          },
        },
        lualine_x = {
          {
            "macro",
            fmt = function()
              local reg = vim.fn.reg_recording()
              if reg ~= "" then
                return "Recording: @" .. reg
              end
              return nil
            end,
            color = { fg = "#ff9e64" },
            draw_empty = false,
          },
          { "searchcount" },
        },
        lualine_y = {
          "filetype",
        },
        lualine_z = {},
      },
    })
  end,
}
