local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup({
  function(use)
    use { "wbthomason/packer.nvim" }

    use { "folke/tokyonight.nvim" } -- Color scheme
    use { "goolord/alpha-nvim" } -- Startup screen
    use {
      "nvim-treesitter/nvim-treesitter",
      run = function()
        local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
        ts_update()
      end,
    }

    -- Telescope
    use {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "xiyaowong/telescope-emoji.nvim" },
        { "ghassan0/telescope-glyph.nvim" },
        {'nvim-telescope/telescope-ui-select.nvim' },
      }
    }

    use {
      "VonHeikemen/lsp-zero.nvim",
      requires = {
        -- LSP Support
        { "neovim/nvim-lspconfig" },
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },

        -- Autocompletion
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-nvim-lua" },
        { "hrsh7th/cmp-cmdline" },
        { "hrsh7th/cmp-nvim-lsp-signature-help" },

        -- Snippets
        { "L3MON4D3/LuaSnip" },
        { "rafamadriz/friendly-snippets" },
        { "onsails/lspkind.nvim" },
      }
    }

    use { "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" } -- Git
    use { "lewis6991/gitsigns.nvim" } -- Git
    use { "folke/which-key.nvim" }
    use { "tpope/vim-commentary" }
    use { "nvim-lualine/lualine.nvim", requires = "nvim-tree/nvim-web-devicons" } -- Status line
    use { "windwp/nvim-autopairs", requires = "nvim-treesitter/nvim-treesitter" }
    use { "windwp/nvim-ts-autotag" }
    use { "nvim-tree/nvim-tree.lua", requires = "nvim-tree/nvim-web-devicons" } -- Tree
    use { "folke/trouble.nvim", requires = "nvim-tree/nvim-web-devicons" } -- Diagnostic
    use { "norcalli/nvim-colorizer.lua" }
    use { "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" } }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require("packer").sync()
    end
  end,
  config = {
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "single" })
      end,
      done_sym = " ",
      working_sym = " ",
      error_sym = "ﮊ ",
      moved_sym = " ",
      removed_sym = " ",
    }
  }
})
