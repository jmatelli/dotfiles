return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local wk = require("which-key")

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

    local normalOpts = {
      mode = "n", -- Normal mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use 'silent' when creating keymaps
      noremap = true, -- use 'noremap' when creating keymaps
      nowait = false, -- use 'nowait' when creating keymaps
    }

    local visualOpts = {
      mode = "v", -- Normal mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use 'silent' when creating keymaps
      noremap = true, -- use 'noremap' when creating keymaps
      nowait = false, -- use 'nowait' when creating keymaps
    }

    local normalMappings = {
      ["w"] = { "<cmd>update!<CR>", "Save" },
      ["Q"] = { "<cmd>qall!<CR>", "Quit" },
      [","] = { "m`A,<Esc>``", "Add colon eol" },
      [";"] = { "m`A;<Esc>``", "Add semi-colon eol" },
      ["o"] = { "o<Esc>k", "Insert new line beneath cursor" },
      ["O"] = { "O<Esc>j", "Insert new line above cursor" },

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
            require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
              winblend = 10,
              previewer = false,
            }))
          end,
          "[/] Fuzzily search in current buffer",
        },
      },

      g = {
        name = "[G]it",
        s = { "<cmd>Neogit<CR>", "[S]tatus" },
        h = { "<cmd>Gitsigns preview_hunk<CR>", "Preview [H]unk" },
        S = { "<cmd>Gitsigns stage_hunk<CR>", "[S]tage Hunk" },
        U = { "<cmd>Gitsigns undo_stage_hunk<CR>", "[U]ndo Stage Hunk" },
        u = { "<cmd>Gitsigns prev_hunk<CR>", "Previous Hunk" },
        d = { "<cmd>Gitsigns next_hunk<CR>", "Next Hunk" },
        r = { "<cmd>Gitsigns reset_hunk<CR>", "[R]eset Hunk" },
        B = { "<cmd>Gitsigns stage_buffer<CR>", "[S]tage Buffer" },
        R = { "<cmd>Gitsigns reset_buffer<CR>", "[R]eset Buffer" },
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
        l = { "<cmd>tMasonLog<CR>", "Show [M]ason [l]ogs" },
        p = { "<cmd>MarkdownPreview<CR>", "[M]arkdown [P]review" },
      },

      n = {
        name = "[N]eotest",
        r = { "<cmd>lua require('neotest').run.run()<CR>", "[R]un Tests" },
        f = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", "Run [F]ile Tests" },
        s = { "<cmd>lua require('neotest').run.stop()<CR>", "[S]top Tests" },
        a = { "<cmd>lua require('neotest').run.attach()<CR>", "[A]ttach Tests" },
        o = { "<cmd>lua require('neotest').output_panel.toggle()<CR>", "[O]pen Tests Output" },
      },

      q = {
        name = "[Q]uickfix List",
        c = { "<cmd>ccl<CR>", "[C]lose Quickfix List" },
      },

      s = {
        name = "Tree[S]J",
        s = { "<cmd>lua require('treesj').split()<CR>", "[S]plit code block" },
        j = { "<cmd>lua require('treesj').join()<CR>", "[J]oin code block" },
        t = { "<cmd>lua require('treesj').toggle()<CR>", "[T]oggle TreeSJ" },
      },

      S = {
        name = "[S]pectre",
        o = { "<cmd>lua require('spectre').open()<CR>", "Open [S]pectre" },
        w = { "<cmd>lua require('spectre').open_visual({ select_word = true })<CR>", "[S]earch Current [W]ord" },
        f = { "<cmd>lua require('spectre').open_file_search({ select_word = true })<CR>", "[S]earch On Current [F]ile" },
      },

      t = {
        name = "[T]rouble/[T]ests",
        c = { "<cmd>TroubleClose<CR>", "[C]lose Trouble" },
        d = { "<cmd>TroubleToggle document_diagnostics<CR>", "[D]ocument diagnostics" },
        f = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", "Run [F]ile [T]est" },
        r = { "<cmd>lua require('neotest').run.run()<CR>", "[R]un nearest [T]est" },
        s = { "<cmd>lua require('neotest').run.stop()<CR>", "[S]top [T]est" },
        t = { "<cmd>TodoTrouble cwd=~/invictus-root/invictus-web<CR>", "Show [T]odos" },
        w = { "<cmd>lua require('neotest').run.run({ jestCommand = 'npm test -- --watch ' })<CR>", "[W]atch [T]ests" }
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

    local visualMappings = {
      s = {
        name = "[S]pectre",
        w = { "<cmd>lua require('spectre').open_visual()<CR>", "[S]earch Current [W]ord" },
      },
    }

    wk.setup(conf)
    wk.register(normalMappings, normalOpts)
    wk.register(visualMappings, visualOpts)
  end
}
