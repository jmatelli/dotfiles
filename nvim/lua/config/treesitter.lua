local M = {}

local file = "config/treesitter.lua"

function M.setup()
  local status_ok, ts = pcall(require, "nvim-treesitter.configs")

  if not status_ok then
    return vim.notify("Could not load nvim-treesitter.configs in " .. file)
  end

  require("nvim-treesitter.install").prefer_git = true

  ts.setup {
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = { "css", "html", "javascript", "tsx", "typescript", "json", "lua", "go" },

    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

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
end

return M
