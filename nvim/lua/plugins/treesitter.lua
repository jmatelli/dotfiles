return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local ts = require("nvim-treesitter.configs")

		require("nvim-treesitter.configs").prefer_git = true

		ts.setup({
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			autotag = {
				enable = true,
				enable_close_on_slash = false,
			},
			autopairs = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					scope_incremental = "<CR>",
					node_incremental = "<TAB>",
					node_decremental = "<S-TAB>",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["<leader>tf"] = "@function.outer",
						["<leader>tc"] = "@class.outer",
					},
					goto_next_end = {
						["<leader>tF"] = "@function.outer",
						["<leader>tC"] = "@class.outer",
					},
					goto_previous_start = {
						["<leader>tg"] = "@function.outer",
						["<leader>tv"] = "@class.outer",
					},
					goto_previous_end = {
						["<leader>tG"] = "@function.outer",
						["<leader>tV"] = "@class.outer",
					},
				},
			},
		})
	end,
}
