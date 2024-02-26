return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				-- formatting
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettierd,
				null_ls.builtins.formatting.ktlint,
				null_ls.builtins.formatting.dart_format,
				-- diagnostics
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.diagnostics.ktlint,
				-- code actions
				null_ls.builtins.code_actions.eslint_d,
				-- snippet
				null_ls.builtins.completion.luasnip,
			},
		})

		vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, {})
	end,
}
