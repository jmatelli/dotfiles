local M = {}

local setHl = require("core.utils").setHl

M.setup = function()
  require("core.utils").load_highlights "nvimtree"
  require("nvim-tree").setup {
    diagnostics = {
      enable = true,
      show_on_dirs = false,
      debounce_delay = 50,
      icons = {
        hint = "",
        info = "",
        warning = "",
        error = "✘",
      },
    },
    filters = {
      dotfiles = false,
    },
    view = {
      adaptive_size = true,
      width = 40,
    },
    git = {
      enable = true,
      ignore = true,
      show_on_dirs = true,
      timeout = 400,
    },
    filesystem_watchers = {
      enable = true,
    },
    actions = {
      open_file = {
        quit_on_open = true,
      }
    }
  }
end

return M
