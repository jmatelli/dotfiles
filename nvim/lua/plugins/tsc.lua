return {
	{
		"dmmulroy/tsc.nvim",
		lazy = true,
		ft = { "typescript", "typescriptreact" },
		config = function()
			require("tsc").setup({
				auto_open_qflist = true,
				auto_close_qflist = true,
				auto_focus_qdflist = true,
				pretty_errors = true,
			})
			vim.keymap.set("n", "<leader>ts", "<CMD>TSC<CR>")
		end,
	},
}
