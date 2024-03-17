return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin",
				-- component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
				-- section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
				component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
				section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },

				disabled_filetypes = {
					statusline = { "alpha" },
				},

				ignore_focus = {
					"TelescopePrompt",
					"alpha",
					"NvimTree",
				},

				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						"tabs",
						tab_max_length = 40,
						max_length = vim.o.columns / 3,
						mode = 0,
						path = 0,
						use_mod_colors = true,
						symbols = {
							modified = "·",
						},
					},
				},
				lualine_b = { "mode", "diff", "diagnostics" },
				lualine_c = {
					{
						"filename",
						path = 3,
						shorting_target = 40,
					},
				},
				lualine_x = {},
				lualine_y = { "filetype" },
				lualine_z = { "branch" },
			},
		})
	end,
}
