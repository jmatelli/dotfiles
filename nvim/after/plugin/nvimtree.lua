local tree = require("nvim-tree")
local utils = require("core.utils")
local default_opts = { noremap = true, silent = true }

utils.nnoremap("<F2>", ":NvimTreeToggle<CR>", default_opts)
utils.nnoremap("<F3>", ":NvimTreeFindFileToggle<CR>", default_opts)

tree.setup {
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
