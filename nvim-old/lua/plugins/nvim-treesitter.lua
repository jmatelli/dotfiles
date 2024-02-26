return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
    ts_update()
  end,
  dependencies = {
    { "JoosepAlviste/nvim-ts-context-commentstring" },
    { "windwp/nvim-ts-autotag" },
  },
  config = function()
    local ts = require("nvim-treesitter.configs")

    require("nvim-treesitter.install").prefer_git = true

    ts.setup({
      -- One of "all", "maintained" (parsers with maintainers), or a list of languages
      ensure_installed = {
        "css",
        "html",
        "javascript",
        "tsx",
        "typescript",
        "json",
        "lua",
        "go",
        "bash",
        "vim",
        "kotlin",
      },

      -- Install languages synchronously (only applied to `ensure_installed`)
      sync_install = false,

      highlight = {
        -- `false` will disable the whole extension
        enable = true,
        disable = {},
        use_languagetree = true,
      },
      indent = {
        enable = true,
        disable = {},
      },
      autotag = {
        enable = true,
        enable_close_on_slash = false,
      },
    })
  end
}
