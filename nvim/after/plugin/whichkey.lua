local whichkey = require("which-key")

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
  ["w"] = { "<cmd>update!<CR>", "Save" },
  ["q"] = { "<cmd>q!<CR>", "Quit" },
  [","] = { "m`A,<Esc>``", "Add colon eol" },
  [";"] = { "m`A;<Esc>``", "Add semi-colon eol" },
  ["noh"] = { "<cmd>noh<bar>:echo<CR>", "No highlight" },

  b = {
    name = "Buffer",
    c = { "<cmd>bd!<CR>", "Close current buffer" },
    D = { "<cmd>%bd|e#|bd#<CR>", "Delete all buffers" },
  },

  f = {
    name = "Telescope",
    b = { "<cmd>Telescope buffers<CR>", "Buffers" },
    c = { "<cmd>Telescope git_commits<CR>", "Git commits" },
    e = { "<cmd>Telescope emoji<CR>", "Emoji" },
    f = { "<cmd>Telescope find_files<CR>", "Find files" },
    g = { "<cmd>Telescope git_files<CR>", "Git files" },
    o = { "<cmd>Telescope oldfiles<CR>", "Old files" },
    w = { "<cmd>Telescope live_grep<CR>", "Find words" },
    z = { "<cmd>Telescope glyph<CR>", "Glyph" },
  },

  g = {
    name = "Git",
    s = { "<cmd>Neogit<CR>", "Status" },
  },

  l = {
    name = "LSP",
    a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "LSP code action" },
    d = { "<cmd>Telescope lsp_definitions<CR>", "LSP document symbols" },
    r = { "<cmd>Telescope lsp_references<CR>", "LSP references" },
    s = { "<cmd>Telescope lsp_document_symbols<CR>", "LSP document symbols" },
  },

  m = {
    name = "Mason/Markdown",
    m = { "<cmd>Mason<CR>", "Open Mason" },
    l = { "<cmd>MasonLog<CR>", "Show Mason logs" },
    p = { "<cmd>MarkdownPreview<CR>" }
  },

  t = {
    name = "Trouble",
    w = { "<cmd>TroubleToggle workspace_diagnostics<CR>", "Workspace diagnostics" },
    d = { "<cmd>TroubleToggle document_diagnostics<CR>", "Document diagnostics" },
    l = { "<cmd>TroubleToggle loclist<CR>", "Loclist" },
    q = { "<cmd>TroubleToggle quickfix<CR>", "Quickfix" },
    R = { "<cmd>TroubleToggle lsp_references<CR>", "LSP references" },
  },

  p = {
    name = "Packer",
    c = { "<cmd>PackerCompile<CR>", "Compile" },
    i = { "<cmd>PackerInstall<CR>", "Install" },
    s = { "<cmd>PackerSync<CR>", "Sync" },
    S = { "<cmd>PackerStatus<CR>", "Status" },
    u = { "<cmd>PackerUpdate<CR>", "Update" },
  },
}

whichkey.setup(conf)
whichkey.register(mappings, opts)
