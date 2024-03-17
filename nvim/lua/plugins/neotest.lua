return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
    "sidlatau/neotest-dart",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-jest")({
          jestCommand = "npm test --",
          env = { CI = true },
          jestConfigFile = function()
            local file = vim.fn.expand("%:p")
            if string.find(file, "/packages/") then
              return string.match(file, "(.-/[^/]+/)src") .. "jest.config.js"
            end
            return vim.fn.getcwd() .. "/jest.config.js"
          end,
          cwd = function()
            return vim.fn.getcwd()
          end,
        }),
        require("neotest-dart")({
          command = "fvm flutter",
          use_lsp = true,
        }),
      },
    })
    vim.api.nvim_set_keymap(
      "n",
      "<leader>tw",
      "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>",
      {}
    )
    vim.api.nvim_set_keymap("n", "<leader>ta", "<cmd>lua require('neotest').run.run()<cr>", {})
    vim.api.nvim_set_keymap("n", "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", {})
  end,
}
