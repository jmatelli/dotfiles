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

  b = {
    name = "[B]uffer",
    c = { "<cmd>bd!<CR>", "[C]lose current buffer" },
    D = { "<cmd>%bd|e#|bd#<CR>", "[D]elete all buffers" },
  },

  f = {
    name = "Telescope",
    b = { "<cmd>Telescope buffers<CR>", "[F]ind [B]uffers" },
    c = { "<cmd>Telescope git_commits<CR>", "[F]ind Git [C]ommits" },
    d = { "<cmd>Telescope diagnostics<CR>", "[F]ind [D]iagnostic" },
    e = { "<cmd>Telescope emoji<CR>", "[F]ind [E]moji" },
    f = { "<cmd>Telescope find_files<CR>", "[F]ind [F]iles" },
    g = { "<cmd>Telescope git_files<CR>", "[F]ind [G]it Files" },
    o = { "<cmd>Telescope oldfiles<CR>", "[F]ind [O]ld Files" },
    w = { "<cmd>Telescope live_grep<CR>", "[F]ind [W]ords" },
    y = { "<cmd>Telescope glyph<CR>", "[F]ind Gl[y]ph" },
    ["/"] = {
      function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end,
      "[/] Fuzzily search in current buffer"
    },
  },

  g = {
    name = "[G]it",
    s = { "<cmd>Neogit<CR>", "[S]tatus" },
  },

  l = {
    name = "[L]SP",
    a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "[L]SP Code [A]ction" },
    d = { "<cmd>Telescope lsp_definitions<CR>", "[L]SP [D]efinitions" },
    r = { "<cmd>Telescope lsp_references<CR>", "[L]SP [R]eferences" },
    s = { "<cmd>Telescope lsp_document_symbols<CR>", "[L]SP Document [S]ymbols" },
  },

  m = {
    name = "[M]ason/[M]arkdown",
    o = { "<cmd>Mason<CR>", "[M]ason [O]pen" },
    l = { "<cmd>MasonLog<CR>", "Show [M]ason [l]ogs" },
    p = { "<cmd>MarkdownPreview<CR>" }
  },

  t = {
    name = "[T]rouble",
    d = { "<cmd>TroubleToggle document_diagnostics<CR>", "Document diagnostics" },
    l = { "<cmd>TroubleToggle loclist<CR>", "Loclist" },
    q = { "<cmd>TroubleToggle quickfix<CR>", "Quickfix" },
    w = { "<cmd>TroubleToggle workspace_diagnostics<CR>", "Workspace diagnostics" },
  },

  p = {
    name = "[P]acker",
    c = { "<cmd>PackerCompile<CR>", "[C]ompile" },
    i = { "<cmd>PackerInstall<CR>", "[I]nstall" },
    s = { "<cmd>PackerSync<CR>", "[S]ync" },
    t = { "<cmd>PackerStatus<CR>", "S[t]atus" },
    u = { "<cmd>PackerUpdate<CR>", "[U]pdate" },
  },
}

whichkey.setup(conf)
whichkey.register(mappings, opts)
