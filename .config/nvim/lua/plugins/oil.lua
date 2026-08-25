return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
  },
  keys = {
    { "-", "<CMD>Oil<CR>", mode = { "n" }, desc = "Open Oil" },
  },
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", version = "*" } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
