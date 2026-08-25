return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sql = { "pg_format" },
        json = { "jq" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        swift = { "swift" },
        go = { "gofumpt", "golangci-lint", "golines" },
      },
    },
  },
}
