vim.pack.add({
  -- File navigation
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-mini/mini.icons",

  -- LSP: mason installs, nvim-lspconfig supplies configs, mason-lspconfig bridges them
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",

  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

  -- Completion (pinned to v1: main is an actively-breaking v2 in progress
  -- per the plugin's own README warning; v1 is the current stable line)
  { src = "https://github.com/Saghen/blink.cmp", version = "v1" },

  -- Fuzzy finder
  "https://github.com/ibhagwan/fzf-lua",

  -- Git
  "https://github.com/lewis6991/gitsigns.nvim",

  -- Statusline
  "https://github.com/nvim-lualine/lualine.nvim",

  -- Formatting
  "https://github.com/stevearc/conform.nvim",

  -- Database
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-ui",
  "https://github.com/kristijanhusak/vim-dadbod-completion",

  -- Theme
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },

  -- AI
  "https://github.com/zbirenbaum/copilot.lua",

  -- Motion discipline
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/m4xshen/hardtime.nvim",
})

require("mini.icons").setup()

require("oil").setup({
  view_options = {
    show_hidden = true,
  },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil" })

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "vtsls", "eslint" },
})

require("blink.cmp").setup({
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      sql = { "snippets", "dadbod", "buffer" },
    },
    providers = {
      dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
    },
  },
  keymap = {
    preset = "default",
  },
})

require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "│" },
    topdelete = { text = "│" },
    changedelete = { text = "│" },
    untracked = { text = "┆" },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 1000,
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
})
vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns toggle_signs<cr>", { desc = "Toggle Git Signs" })
vim.keymap.set("n", "<leader>gn", "<cmd>Gitsigns next_hunk<cr>", { desc = "Next Git Hunk" })
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Previous Git Hunk" })
vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset Git Hunk" })
vim.keymap.set("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Reset Git Buffer" })

require("lualine").setup({
  options = {
    theme = "rose-pine",
    component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
    section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      "diff",
      {
        "diagnostics",
        symbols = {
          error = " ",
          warn = " ",
          info = " ",
          hint = " ",
        },
      },
    },
    lualine_c = {
      {
        "filename",
        path = 1,
        file_status = true,
        newfile_status = true,
      },
    },
    lualine_x = {
      {
        "macro",
        fmt = function()
          local reg = vim.fn.reg_recording()
          if reg ~= "" then
            return "Recording: @" .. reg
          end
          return nil
        end,
        color = { fg = "#ff9e64" },
        draw_empty = false,
      },
      { "searchcount" },
    },
    lualine_y = { "filetype" },
    lualine_z = {},
  },
})

require("conform").setup({
  formatters_by_ft = {
    sql = { "pg_format" },
    json = { "jq" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    go = { "gofumpt", "golangci-lint", "golines" },
  },
  format_on_save = function(bufnr)
    -- golangci-lint does real static analysis (not just text formatting),
    -- confirmed to reliably exceed 500ms even on a small package - tested
    -- directly, the exact same formatter chain completes correctly at
    -- ~2-3s. Go gets a longer budget. Everything else also got bumped
    -- from LazyVim's 500ms default to 1000ms - prettierd's daemon
    -- cold-start measurably exceeded 500ms in testing too; a higher
    -- timeout is a ceiling, not a floor, so this costs nothing when a
    -- formatter finishes fast.
    if vim.bo[bufnr].filetype == "go" then
      return { timeout_ms = 5000, lsp_format = "fallback" }
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
})

vim.o.previewheight = 30
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_use_nvim_notify = 1
local urlprefix = "postgresql://postgres:postgres@" .. (vim.env.LOCAL_IP or "127.0.0.1") .. ":5432/"
vim.g.dbs = {
  { name = "Yaarz - DEV", url = urlprefix .. "yaarz" },
  { name = "Yaarz - TEST", url = urlprefix .. "yaarz_test" },
  { name = "Yaarz - E2E TEST", url = urlprefix .. "yaarz_e2e_test" },
  { name = "Yaarz - STG readonly", url = vim.env.YAARZ_READONLY_STG_DB_URL },
  { name = "Yaarz - STG", url = vim.env.YAARZ_STG_DB_URL },
  { name = "Yaarz - PROD readonly", url = vim.env.YAARZ_PROD_READONLY_DB_URL },
  { name = "Yaarz - PROD", url = vim.env.YAARZ_PROD_DB_URL },
  {
    name = "Metabase",
    url = "postgresql://***REMOVED***:***REMOVED***@***REMOVED***/***REMOVED***",
  },
}
vim.keymap.set("n", "<leader>D", "<cmd>bd<cr><cmd>DBUIToggle<cr>")

require("rose-pine").setup({
  variant = "moon",
  dark_variant = "moon",
  styles = {
    transparency = true,
  },
})
vim.cmd.colorscheme("rose-pine")

require("copilot").setup({
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = "<M-y>",
      next = "<M-l>",
      prev = "<M-h>",
      dismiss = "<M-x>",
    },
  },
})

require("hardtime").setup({
  disabled_filetypes = { "dbui", "dbout", "oil" },
})
vim.keymap.set({ "n", "x" }, "j", 'v:count == 0 ? "gj" : "j"', { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", 'v:count == 0 ? "gj" : "j"', { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", 'v:count == 0 ? "gk" : "k"', { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", 'v:count == 0 ? "gk" : "k"', { desc = "Up", expr = true, silent = true })

require("fzf-lua").setup({
  file_ignore_patterns = { "node_modules", "mocks" },
})
vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Switch Buffers" })
vim.keymap.set("n", "<C-P>", "<cmd>FzfLua files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep (cwd)" })
