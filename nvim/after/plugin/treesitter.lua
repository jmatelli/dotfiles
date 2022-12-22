local ts = require("nvim-treesitter.configs")

require("nvim-treesitter.install").prefer_git = true

ts.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = { "css", "html", "javascript", "tsx", "typescript", "json", "lua", "go", "bash", "vim" },

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
  },
}
