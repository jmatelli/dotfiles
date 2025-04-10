-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },
-- separator = { left = "", right = "" },

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "nord",
				component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
				section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
				ignore_focus = {
					"TelescopePrompt",
					"alpha",
					"NvimTree",
				},
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"diff",
					{
						"diagnostics",
						symbols = {
							error = " ",
							warn = " ",
							info = " ",
							hint = " ",
						},
					},
				},
				lualine_c = {
					{
						"filename",
						path = 1,
						file_status = true,
						newfile_status = true,
					},
				},
				lualine_x = {
					"searchcount",
					{
						function()
							local nbTab = 0

							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_get_option(buf, "modified") then
									nbTab = nbTab + 1
								end
							end

							if nbTab > 0 then
								return "󰗮 " .. nbTab
							end

							return ""
						end,
						color = { fg = "#BF616A" },
					},
				},
				lualine_y = {
					"filetype",
				},
				lualine_z = {},
			},
		})
	end,
}
