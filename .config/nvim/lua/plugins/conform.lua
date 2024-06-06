return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = { "ConformInfo" },
	lazy = true,
	keys = {
		{
			"<leader>fm",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	config = function()
		local slow_format_filetypes = {}
		require("conform").setup({
			notify_on_error = false,

			format_on_save = function(bufnr)
				if slow_format_filetypes[vim.bo[bufnr].filetype] then
					return
				end
				local function on_format(err)
					if err and err:match("timeout$") then
						slow_format_filetypes[vim.bo[bufnr].filetype] = true
					end
				end

				return { timeout_ms = 200, lsp_fallback = true }, on_format
			end,

			format_after_save = function(bufnr)
				if not slow_format_filetypes[vim.bo[bufnr].filetype] then
					return
				end
				return { lsp_fallback = true }
			end,

			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { { "prettierd", "prettier" }, { "eslint_d" } },
				javascriptreact = { { "prettierd", "prettier" }, { "eslint_d" } },
				typescript = { { "prettierd", "prettier" }, { "eslint_d" } },
				typescriptreact = { { "prettierd", "prettier" }, { "eslint_d" } },
				css = { "stylelint" },
				go = { "gofumpt", "goimports", "golines" },
				json = { "yq" },
				yaml = { "yq" },
			},
		})
	end,
}
