return {
	"catppuccin/nvim",
	lazy = false,
	name = "catppuccin",
	priority = 1000,
	config = function()
		local mocha = require("catppuccin.palettes").get_palette("mocha")

		require("catppuccin").setup({
			flavor = "mocha",
			integrations = {
				cmp = true,
				gitsigns = true,
				indent_blankline = {
					enabled = false,
					scope_color = "sapphire",
					colored_indent_levels = false,
				},
				mason = true,
				native_lsp = { enable = true },
				neotree = true,
				telescope = true,
				treesitter = true,
				treesitter_context = true,
			},
			custom_highlights = {
				["@constructor.tsx"] = { fg = mocha.red },
				["@tag.tsx"] = { fg = mocha.red },
				["@tag"] = { fg = mocha.pink },
				["@tag.delimiter.tsx"] = { fg = mocha.mauve },
				["@tag.delimiter"] = { fg = mocha.mauve },
			},
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
