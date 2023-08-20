local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "goolord/alpha-nvim" },
	{ "norcalli/nvim-colorizer.lua" },
	{ "RRethy/vim-illuminate" }, -- Highlight refs on hover
	{ "tpope/vim-fugitive" },
	{ "lukas-reineke/indent-blankline.nvim" },
	{ "folke/tokyonight.nvim", lazy = false, priority = 1000 },
	{ "nvim-lualine/lualine.nvim", lazy = true },
	{ "nvim-tree/nvim-tree.lua", lazy = true },
	{ "nvim-pack/nvim-spectre", dependencies = "nvim-lua/plenary.nvim", config = true },
	{ "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
	{ "echasnovski/mini.indentscope", config = true, version = "*" },
	{ "echasnovski/mini.surround", config = true, version = "*" },
	{ "echasnovski/mini.comment", version = "*" },
	{ "folke/trouble.nvim", config = true, dependencies = "nvim-tree/nvim-web-devicons" },
	{ "folke/todo-comments.nvim", config = true, dependencies = "nvim-lua/plenary.nvim" },
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		dependencies = {
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			{ "windwp/nvim-ts-autotag" },
		},
	},

	{
		"Wansmer/treesj",
		keys = { "<space>m", "<space>j", "<space>s" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {},
	},

	{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },

	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "xiyaowong/telescope-emoji.nvim" },
			{ "ghassan0/telescope-glyph.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
	},

	-- Fuzzy Finder Algorithm which requires local dependencies to be built.
	-- Only load if `make` is available
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		cond = vim.fn.executable("make") == 1,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- LSP Support
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "nvimdev/guard.nvim" },

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

			-- Languages
			{ "b0o/schemastore.nvim" },
		},
	},

	{
		"nvim-tree/nvim-web-devicons",
		lazy = false,
		priority = 999,
		opts = {
			default = true,
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
		},
	},
})
