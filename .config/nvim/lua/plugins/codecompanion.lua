return {
  "olimorris/codecompanion.nvim",
  opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/mcphub.nvim",
  },
  config = function()
    require("codecompanion").setup({
      extension = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
      strategies = {
        chat = {
          adapter = "anthropic",
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    })

    -- Optional: Set up key mappings for code companion features
    local keymap = vim.keymap.set
    keymap("n", "<leader>ap", "<cmd>CodeCompanion<cr>", { desc = "Open Code Companion" })
    keymap("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "Open Code Companion Chat" })
    keymap("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Open Code Companion Actions" })
  end,
}
