return {
	{
		"echasnovski/mini.comment",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		version = "*",
		lazy = false,
		config = function()
			require("mini.comment").setup({
				options = {
					custom_commentstring = function()
						require("ts_context_commentstring").setup({})
						vim.g.skip_ts_context_commentstring_module = true
					end,
				},
			})
		end,
	},
	{
		"folke/ts-comments.nvim",
		opts = {},
		event = "VeryLazy",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
}
