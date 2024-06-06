return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		lazy = true,
		opts = {
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<M-y>",
					next = "<M-l>",
					prev = "<M-h>",
					dismiss = "<M-x>",
				},
			},
		},
	},
}
