return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gdiff" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
      { "<leader>gb", "<cmd>Gblame<cr>", desc = "Git Blame" },
      { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git Diff" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "│" },
        topdelete = { text = "│" },
        changedelete = { text = "│" },
        untracked = { text = "┆" },
      },
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000, -- ms
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> - <summary>",
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    },
    keys = {
      { "<leader>gs", "<cmd>Gitsigns toggle_signs<cr>", desc = "Toggle Git Signs" },
      { "<leader>gn", "<cmd>Gitsigns next_hunk<cr>", desc = "Next Git Hunk" },
      { "<leader>gp", "<cmd>Gitsigns prev_hunk<cr>", desc = "Previous Git Hunk" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Git Hunk" },
      { "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset Git Buffer" },
    },
  },
}
