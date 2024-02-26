return {
	"echasnovski/mini.indentscope",
	version = "*",
	opts = {
		draw = {
			delay = 0,
			animation = function()
				return 0
			end,
		},
		symbol = "▏",
		-- symbol = "│",
		options = { try_as_border = true },
	},
	config = function(_, opts)
		require("mini.indentscope").setup(opts)
		-- Disable for certain filetypes
		vim.api.nvim_create_autocmd({ "FileType" }, {
			desc = "Disable indentscope for certain filetypes",
			callback = function()
				local ignore_filetypes = {
					"dashboard",
					"help",
					"lazy",
					"mason",
					"neo-tree",
					"Trouble",
					"alpha",
				}
				if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
					vim.b.miniindentscope_disable = true
				end
			end,
		})
	end,
}
