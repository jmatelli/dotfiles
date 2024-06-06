return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			{
				"<leader>dB",
				"<CMD>DapToggleBreakpoint<CR>",
				"Toggle breakpoint",
			},
			{
				"<leader>dus",
				function()
					local widgets = require("dap.ui.widgets")
					local sidebar = widgets.sidebar(widgets.scopes)
					sidebar.open()
				end,
				"Open debugging sidebar",
			},
		},
	},
	{
		"leoluz/nvim-dap-go",
		ft = { "go" },
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = true,
		keys = {
			{
				"<leader>dgt",
				function()
					require("dap-go").debug_test()
				end,
				"Debug go test",
			},
			{
				"<leader>dgl",
				function()
					require("dap-go").debug_last()
				end,
				"Debug last go test",
			},
		},
	},
	{ "folke/neodev.nvim", config = true },
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
		opts = {
			ensure_installed = {
				"gopls",
				"eslint-lsp",
				"prettierd",
				"typescript-language-server",
				"tailwindcss-language-server",
				"lua-language-server",
				"stylua",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)

			-- custom nvchad cmd to install all mason binaries listed
			vim.api.nvim_create_user_command("MasonInstallAll", function()
				if opts.ensure_installed and #opts.ensure_installed > 0 then
					vim.cmd("Mason")
					local mr = require("mason-registry")

					mr.refresh(function()
						for _, tool in ipairs(opts.ensure_installed) do
							local p = mr.get_package(tool)
							if not p:is_installed() then
								p:install()
							end
						end
					end)
				end
			end, {})

			vim.g.mason_binaries_list = opts.ensure_installed
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = true,
		opts = {
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem = {
				documentationFormat = { "markdown", "plaintext" },
				snippetSupport = true,
				preselectSupport = true,
				insertReplaceSupport = true,
				labelDetailsSupport = true,
				deprecatedSupport = true,
				commitCharactersSupport = true,
				tagSupport = { valueSet = { 1 } },
				resolveSupport = {
					properties = {
						"documentation",
						"detail",
						"additionalTextEdits",
					},
				},
			}
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local on_init = function(client, _)
				if client.supports_method("textDocument/semanticTokens") then
					client.server_capabilities.semanticTokensProvider = nil
				end
			end

			local on_attach = function(event)
				local telescope = require("telescope.builtin")

				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = event.buf }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "gd", telescope.lsp_definitions, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gr", telescope.lsp_references, opts)
				vim.keymap.set("n", "gi", function()
					telescope.lsp_implementations({ file_ignore_patterns = { "mocks/" } })
				end, opts)
				vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>td", telescope.lsp_type_definitions, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			end

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_init = on_init,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { "vim" },
						},
					},
				},
			})

			local util = require("lspconfig/util")

			lspconfig.gopls.setup({
				capabilities = capabilities,
				on_init = on_init,
				on_attach = on_attach,
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = util.root_pattern("go.work", "go.mod", ".git"),
				settings = {
					gopls = {
						completeUnimported = true,
						usePlaceholders = true,
						analyses = {
							unusedparams = true,
						},
					},
				},
			})

			local servers = {
				"tsserver",
				"tailwindcss",
				"eslint",
			}

			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					on_init = on_init,
					filetypes = {
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"css",
						"scss",
						"html",
						"json",
					},
				})
			end

			-- global mappings
			vim.keymap.set("n", "<S-d>", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<S-u>", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist)
			vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float)
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		event = "VeryLazy",
		ft = { "lua", "javascript", "typescript", "javascriptreact", "typescriptreact", "go" },
		opts = function()
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			local null = require("null-ls")
			return {
				sources = {
					null.builtins.formatting.stylua,
					null.builtins.formatting.prettierd,
					null.builtins.formatting.gofumpt,
					null.builtins.formatting.goimports_reviser,
				},
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr })
							end,
						})
					end
				end,
			}
		end,
	},
	{
		"olexsmir/gopher.nvim",
		ft = { "go" },
		config = true,
		build = function()
			vim.cmd([[silent! GoInstallDeps]])
		end,
		keys = {
			{
				"<leader>gsj",
				"<CMD>GoTagAdd json<CR>",
				"Add json struct tag",
			},
		},
	},
}
