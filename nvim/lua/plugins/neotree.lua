return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			default_component_configs = {
				file_size = { enabled = false },
				type = { enabled = false },
				last_modified = { enabled = false },
				created = { enabled = false },
			},
			window = {
				width = 80,
				mappings = {
					["<C-x"] = "open_split",
					["<C-v"] = "open_vsplit",
					["<C-t"] = "open_tabnew",
				},
			},
			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
			},
			event_handlers = {
				{
					event = "file_opened",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
		})
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem toggle left<CR>", {})
	end,
}
