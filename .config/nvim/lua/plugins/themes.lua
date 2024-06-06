return {
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
				flavor = "mocha",
				integrations = {
					cmp = true,
					gitsigns = true,
					mason = true,
					native_lsp = { enable = true },
					neotree = true,
					telescope = true,
					treesitter = true,
					treesitter_context = true,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
				},
				custom_highlights = function(colors)
					return {
						["@constructor.tsx"] = { fg = colors.red },
						["@tag.tsx"] = { fg = colors.red },
						["@tag"] = { fg = colors.pink },
						["@tag.delimiter.tsx"] = { fg = colors.mauve },
						["@tag.delimiter"] = { fg = colors.mauve },
						LineNr = { fg = colors.overlay1 },
						CursorLineNr = { fg = colors.teal, bold = true },
					}
				end,
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				transparent = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
				},
				on_highlights = function(highlights, colors)
					highlights["@constructor.tsx"] = { fg = colors.red1 }
					highlights["@tag.tsx"] = { fg = colors.red }
					highlights["@tag"] = { fg = colors.red1 }
					highlights["@tag.delimiter.tsx"] = { fg = colors.magenta2 }
					highlights["@tag.delimiter"] = { fg = colors.magenta2 }
					highlights.LineNr = { fg = colors.teal }
					highlights.CursorLineNr = { fg = colors.teal, bold = true }
				end,
			})
		end,
	},
	{
		"navarasu/onedark.nvim",
		opts = {
			style = "cool",
			transparent = true,
		},
	},
}
