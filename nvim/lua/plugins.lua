local M = {}

local file = "plugins.lua"

function M.setup()
  -- Indicate first time installation
  local packer_bootstrap = false

  -- packer.nvim configuration
  local conf = {
    profile = {
      enable = true,
      threshold = 1, -- The amount in ms that a plugins load time must be over for it to be included in the profile
    },

    display = {
      open_fn = function()
        return require("packer.util").float { border = "rounded" }
      end,
    },
  }

  -- Check if packer.nvim is installed
  -- Run PackerCompile if there are changes in this file
  local function packer_init()
    local fn = vim.fn
    local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
      packer_bootstrap = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
      }
      vim.cmd [[packadd packer.nvim]]
    end
    vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
  end

  -- Plugins
  local function plugins(use)
    use { "wbthomason/packer.nvim" }

    -- Load only when require
    use { "nvim-lua/plenary.nvim", module = "plenary" }

    -- Colorscheme
    -- use {
    --   "dracula/vim",
    --   config = function()
    --     vim.cmd "colorscheme dracula"
    --   end,
    -- }
    use {
      "folke/tokyonight.nvim",
      config = function()
        require("config.tokyonight").setup()
      end,
    }

    -- Startup screen
    use {
      "goolord/alpha-nvim",
      config = function()
        require("config.alpha").setup()
      end,
    }

    -- Git
    use {
      "TimUntersberger/neogit",
      cmd = "Neogit",
      requires = "nvim-lua/plenary.nvim",
      config = function()
        require("config.neogit").setup()
      end,
    }
    use {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup {
          current_line_blame = true,
        }
      end,
    }

    -- WhichKey
    use {
      "folke/which-key.nvim",
      event = "VimEnter",
      config = function()
        require("config.whichkey").setup()
      end,
    }

    -- IndentLine
    use {
      "lukas-reineke/indent-blankline.nvim",
      setup = function()
        require("core.lazy_load").on_file_open "indent-blankline.nvim"
      end,
      config = function()
        require("config.indentblankline").setup()
      end,
    }

    -- Better icons
    use {
      "kyazdani42/nvim-web-devicons",
      module = "nvim-web-devicons",
      config = function()
        require("nvim-web-devicons").setup { default = true }
      end,
    }

    use "tpope/vim-commentary"

    -- Status line
    use {
      "nvim-lualine/lualine.nvim",
      event = "VimEnter",
      config = function()
        require("config.lualine").setup()
      end,
      requires = { "nvim-web-devicons" },
    }

    -- LSP
    use {
      "neovim/nvim-lspconfig",
      opt = true,
      setup = function()
        require("core.lazy_load").on_file_open "nvim-lspconfig"
      end,
      config = function()
        require("config.lspconfig").setup()
      end,
    }
    use {
      "williamboman/mason.nvim",
      module = "mason",
      cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
      config = function()
        require("config.mason").setup()
      end,
    }
    use 'williamboman/mason-lspconfig.nvim'

    -- Treesitter
    use {
      "nvim-treesitter/nvim-treesitter",
      module = "nvim-treesitter",
      setup = function()
        require("core.lazy_load").on_file_open "nvim-treesitter"
      end,
      cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSEnable", "TSDisable", "TSModuleInfo" },
      config = function()
        require("config.treesitter").setup()
      end,
      run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    }

    -- Telescope
    use {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      requires = { "nvim-lua/plenary.nvim" },
      config = function()
        require("config.telescope").setup()
      end,
    }
    use { 'xiyaowong/telescope-emoji.nvim' }
    use { 'ghassan0/telescope-glyph.nvim' }

    -- Completion
    use {
      "rafamadriz/friendly-snippets",
      module = "cmp_nvim_lsp",
      event = "InsertEnter",
    }
    use {
      "onsails/lspkind.nvim",
      requires = "rafamadriz/friendly-snippets",
    }
    use {
      "L3MON4D3/LuaSnip",
      requires = "rafamadriz/friendly-snippets",
      -- config = function()
      --   require("config.luasnip").setup()
      -- end,
    }
    use {
      "hrsh7th/nvim-cmp",
      requires = { "L3MON4D3/LuaSnip", "onsails/lspkind.nvim"},
      -- config = function()
      --   require("config.cmp").setup()
      -- end,
    }
    use {
      "saadparwaiz1/cmp_luasnip",
      requires = "L3MON4D3/LuaSnip",
    }
    use "hrsh7th/cmp-nvim-lua"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-cmdline"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-nvim-lsp-signature-help"

    -- Formatting
    use {
      "windwp/nvim-autopairs",
      after = { "nvim-cmp", "nvim-treesitter" },
      config = function()
        require("config.autopairs").setup()
      end,
    }

    use {
      'windwp/nvim-ts-autotag',
      after = { "nvim-treesitter" },
    }

    -- Tree
    use {
      "kyazdani42/nvim-tree.lua",
      requires = {
        "kyazdani42/nvim-web-devicons", -- optional, for file icons
      },
      config = function()
        require("config.nvimtree").setup()
      end,
    }

    -- Diagnostic
    use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("trouble").setup()
      end,
    }

    use {
      "jose-elias-alvarez/null-ls.nvim",
      requires = { "nvim-lua/plenary.nvim" },
      config = function()
        require("config.null-ls").setup()
      end,
    }

    use {
      "norcalli/nvim-colorizer.lua",
      setup = function()
        require("core.lazy_load").on_file_open "nvim-colorizer.lua"
      end,
      config = function()
        require("config.colorizer").setup()
      end
    }

    use {
      'VonHeikemen/lsp-zero.nvim',
      requires = {
        -- LSP Support
        {'neovim/nvim-lspconfig'},
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},

        -- Autocompletion
        {'hrsh7th/nvim-cmp'},
        {'hrsh7th/cmp-buffer'},
        {'hrsh7th/cmp-path'},
        {'saadparwaiz1/cmp_luasnip'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/cmp-nvim-lua'},

        -- Snippets
        {'L3MON4D3/LuaSnip'},
        {'rafamadriz/friendly-snippets'},
      }
    }

    if packer_bootstrap then
      print "Restart Neovim required after installation!"
      require("packer").sync()
    end
  end

  packer_init()

  local status_ok, packer = pcall(require, "packer")

  if not status_ok then
    vim.notify("Could not load packer in " .. file)
    return
  end

  packer.init(conf)
  packer.startup(plugins)
end

return M
