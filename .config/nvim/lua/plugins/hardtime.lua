return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
  lazy = false,
  opts = {
    disabled_filetypes = { "dbui", "dbout", "oil" },
  },
  keys = {
    { "j", false },
    { "k", false },
    { "<Down>", false },
    { "<Up>", false },
    { "j", 'v:count == 0 ? "gj" : "j"', mode = { "n", "x" }, desc = "Down", expr = true, silent = true },
    { "<Down>", 'v:count == 0 ? "gj" : "j"', mode = { "n", "x" }, desc = "Down", expr = true, silent = true },
    { "k", 'v:count == 0 ? "gk" : "k"', mode = { "n", "x" }, desc = "Up", expr = true, silent = true },
    { "<Up>", 'v:count == 0 ? "gk" : "k"', mode = { "n", "x" }, desc = "Up", expr = true, silent = true },
  },
  config = function()
    require("hardtime").setup()
  end,
}
