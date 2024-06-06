return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod" },
		{ "kristijanhusak/vim-dadbod-completion" },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_use_nvim_notify = 1
		vim.g.dbs = {
			{ name = "Yaarz - DEV", url = "postgresql://postgres:postgres@localhost:5432/yaarz" },
		}
	end,
	keys = {
		{ "<leader>db", "<cmd>bd<cr><cmd>DBUIToggle<cr>" },
	},
}
