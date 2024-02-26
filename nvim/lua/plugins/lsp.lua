return {
	{ "folke/neodev.nvim", opts = {} },
	{
		-- this plugin is still in beta
		"pmizio/typescript-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {},
	},
	{
		"akinsho/flutter-tools.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim", -- optional for vim.ui.select
		},
		config = true,
	},
	{
		"williamboman/mason.nvim",
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "tsserver" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "udalov/kotlin-vim" },
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			lspconfig.lua_ls.setup({
				on_attach = function(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format()
						end,
					})
				end,
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { "vim" },
						},
					},
				},
			})
			lspconfig.eslint.setup({
				on_attach = function(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
				capabilities = capabilities,
			})

			local function filter(arr, fn)
				if type(arr) ~= "table" then
					return arr
				end

				local filtered = {}
				for k, v in pairs(arr) do
					if fn(v, k, arr) then
						table.insert(filtered, v)
					end
				end

				return filtered
			end

			local function filterReactDTS(value)
				return string.match(value.targetUri, "%.d.ts") == nil
			end

			-- lspconfig.tsserver.setup({
			--   capabilities = capabilities,
			--   handlers = {
			--     ["textDocument/definition"] = function(err, result, method, ...)
			--       if vim.tbl_islist(result) and #result > 1 then
			--         local filtered_result = filter(result, filterReactDTS)
			--         return vim.lsp.handlers["textDocument/definition"](err, filtered_result, method, ...)
			--       end
			--
			--       vim.lsp.handlers["textDocument/definition"](err, result, method, ...)
			--     end,
			--   },
			-- })
			require("typescript-tools").setup({
				capabilities = capabilities,
				handlers = {
					["textDocument/definition"] = function(err, result, method, ...)
						if vim.tbl_islist(result) and #result > 1 then
							local filtered_result = filter(result, filterReactDTS)
							return vim.lsp.handlers["textDocument/definition"](err, filtered_result, method, ...)
						end

						vim.lsp.handlers["textDocument/definition"](err, result, method, ...)
					end,
				},
			})

			lspconfig.dartls.setup({
				capabilities = capabilities,
				cmf = { "dart", "language-server", "--protocol=lsp" },
			})
			require("flutter-tools").setup({}) -- use defaults

			lspconfig.kotlin_language_server.setup({
				capabilities = capabilities,
			})

			lspconfig.gopls.setup({
				capabilities = capabilities,
			})

			-- global mappings
			vim.keymap.set("n", "<S-d>", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "<S-u>", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist)
			vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>td", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				end,
			})
		end,
	},
}
