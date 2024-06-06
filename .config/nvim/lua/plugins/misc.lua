return {
	{
		"echasnovski/mini.diff",
		version = false,
		config = function()
			require("mini.diff").setup()
		end,
	},
	{ "echasnovski/mini.notify", version = false, config = true },
	{
		"echasnovski/mini.move",
		version = false,
		config = function()
			require("mini.move").setup()
		end,
	},
	"RRethy/vim-illuminate",
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
	"cohama/lexima.vim", -- autopairs
	"tpope/vim-fugitive",

	-- aesthetics
	{
		"brenoprata10/nvim-highlight-colors",
		event = "VeryLazy",
		opts = {
			enable_tailwind = true,
		},
	},
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
}
