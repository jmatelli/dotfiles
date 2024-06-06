require("formatter").setup {
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    javascript = {
      require("formatter.filetypes.javascript").prettierd,
      require("formatter.filetypes.javascript").eslint_d,
    },
    javascriptreact = {
      require("formatter.filetypes.javascriptreact").prettierd,
      require("formatter.filetypes.javascriptreact").eslint_d,
    },
    typescript = {
      require("formatter.filetypes.typescript").prettierd,
      require("formatter.filetypes.typescript").eslint_d,
    },
    typescriptreact = {
      require("formatter.filetypes.typescriptreact").prettierd,
      require("formatter.filetypes.typescriptreact").eslint_d,
    },

    lua = {
      require("formatter.filetypes.lua").stylua,
    },

    ["*"] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      require("formatter.filetypes.any").remove_trailing_whitespace
    }
  }
}

require("lint").linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  lua = { "luacheck" },
  kotlin = { "ktlint" },
}
