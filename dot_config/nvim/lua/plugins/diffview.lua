return {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    diff_binaries = false, -- Show diffs for binaries
    enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
    use_icons = true, -- Requires nvim-web-devicons
    icons = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
    },
    signs = {
      fold_closed = "",
      fold_open = "",
      done = "✓",
    },
    file_panel = {
      listing_style = "tree", -- One of 'list' or 'tree'
      tree_options = {
        flatten_dirs = true, -- Flatten dirs that only contain one single dir
        folder_statuses = "only_folded", -- One of 'never', 'only_folded', 'always'
      },
    },
    default_args = {
      git = {
        Diff = { "--color=always" }, -- Default args for git diff cmd
        DiffSplit = { "--color=always" }, -- Default args for git diff split cmd
      },
    },
    keymaps = {
      view = {
        ["<tab>"] = "<cmd>DiffviewToggleFiles<cr>",
        ["<leader>q"] = "<cmd>DiffviewClose<cr>",
        ["<leader>r"] = "<cmd>DiffviewRefresh<cr>",
        ["<leader>c"] = "<cmd>DiffviewClose<cr>",
      },
      file_panel = {
        ["<leader>q"] = "<cmd>DiffviewClose<cr>",
        ["<leader>r"] = "<cmd>DiffviewRefresh<cr>",
        ["<leader>c"] = "<cmd>DiffviewClose<cr>",
      },
      file_history_panel = {
        ["<leader>q"] = "<cmd>DiffviewClose<cr>",
        ["<leader>r"] = "<cmd>DiffviewRefresh<cr>",
        ["<leader>c"] = "<cmd>DiffviewClose<cr>",
      },
      file_history = {
        ["<leader>q"] = "<cmd>DiffviewClose<cr>",
        ["<leader>r"] = "<cmd>DiffviewRefresh<cr>",
        ["<leader>c"] = "<cmd>DiffviewClose<cr>",
      },
    },
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
    {
      "<leader>gD",
      "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<cr>",
      desc = "Open diff view between this branch and develop",
    },
    { "<leader>gr", "<cmd>DiffviewRefresh<cr>", desc = "Refresh diff view" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
  },
  lazy = true,
  enabled = true,
  priority = 1000,
  cond = function()
    return vim.fn.executable("git") == 1
  end,
}
