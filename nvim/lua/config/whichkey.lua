local M = {}

local file = "config/whichkey.lua"

function M.setup()
  local status_ok, whichkey = pcall(require, "which-key")

  if not status_ok then
    vim.notify("Could not load which-key in " .. file)
    return
  end

  local conf = {
    window = {
      border = "none", -- none, single, double, shadow
      position = "bottom", -- bottom, top
    },

    layout = {
      spacing = 10,
      align = "center",
    },

    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "  ", -- symbol used between a key and it's label
      group = "", -- symbol prepended to a group
    },

    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "<cr>", "<Cr>", "ˆ:" },
  }

  local opts = {
    mode = "n", -- Normal mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use 'silent' when creating keymaps
    noremap = true, -- use 'noremap' when creating keymaps
    nowait = false, -- use 'nowait' when creating keymaps
  }

  local mappings = {
    ["w"] = { "<cmd>update!<cr>", "Save" },
    ["q"] = { "<cmd>q!<cr>", "Quit" },
    [","] = { "m`A,<Esc>``", "Add colon eol" },
    [";"] = { "m`A;<Esc>``", "Add semi-colon eol" },
    ["noh"] = { "<cmd>noh<bar>:echo<cr>", "No highlight" },

    b = {
      name = "Buffer",
      c = { "<cmd>bd!<cr>", "Close current buffer" },
      D = { "<cmd>%bd|e#|bd#<cr>", "Delete all buffers" },
    },

    f = {
      name = "Telescope",
      f = { "<cmd>Telescope find_files<cr>", "Find files" },
      w = { "<cmd>Telescope live_grep<cr>", "Find words" },
      g = { "<cmd>Telescope git_files<cr>", "Git files" },
      c = { "<cmd>Telescope git_commits<cr>", "Git commits" },
      b = { "<cmd>Telescope buffers<cr>", "Buffers" },
      o = { "<cmd>Telescope oldfiles<cr>", "Old files" },
    },

    g = {
      name = "Git",
      s = { "<cmd>Neogit<cr>", "Status" },
    },

    m = {
      name = "Mason",
      m = { "<cmd>Mason<cr>", "Open Mason" },
      l = { "<cmd>MasonLog<cr>", "Show Mason logs" },
    },

    t = {
      name = "Trouble",
      w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace diagnostics" },
      d = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document diagnostics" },
      l = { "<cmd>TroubleToggle loclist<cr>", "Loclist" },
      q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix" },
      R = { "<cmd>TroubleToggle lsp_references<cr>", "LSP references" },
    },

    z = {
      name = "Packer",
      c = { "<cmd>PackerCompile<cr>", "Compile" },
      i = { "<cmd>PackerInstall<cr>", "Install" },
      s = { "<cmd>PackerSync<cr>", "Sync" },
      S = { "<cmd>PackerStatus<cr>", "Status" },
      u = { "<cmd>PackerUpdate<cr>", "Update" },
    },
  }

  whichkey.setup(conf)
  whichkey.register(mappings, opts)
end

return M
