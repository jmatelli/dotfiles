local M = {}

local file = "config/lspconfig.lua"

local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  require("core.mappings").lspconfig(bufnr)
end

M.setup = function()
  -- local status_ok, lspconfig = pcall(require, "lspconfig")
  local status_ok_lsp_zero, lsp = pcall(require,"lsp-zero")
  local status_ok_utils, utils = pcall(require, "core.utils")

  -- if not status_ok then
  --   vim.notify("Could not load lspconfig in " .. file)
  --   return
  -- end

  if not status_ok_lsp_zero then
    vim.notify("Could not load lsp-zero in " .. file)
    return
  end

  if not status_ok_utils then
    vim.notify("Could not load core.utils in " .. file)
    return
  end

  require("core.mappings").diagnostic()

  utils.load_highlights "diagnostic"

  require("mason.settings").set({
    ui = {
      border = "rounded",
    }
  })

  lsp.preset("recommended")
  lsp.set_preferences({
    set_lsp_keymaps = false,
    configure_diagnostics = false,
    sign_icons = {
      error = "✘",
      warn = "",
      hint = "",
      info = ""
    }
  })
  lsp.ensure_installed({
    "tsserver",
    "eslint",
    "sumneko_lua",
    "gopls",
  })
  lsp.nvim_workspace()
  lsp.on_attach(on_attach)
  lsp.setup()

  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities.textDocument.completion.completionItem = {
  --   documentationFormat = { "markdown", "plaintext" },
  --   snippetSupport = true,
  --   preselectSupport = true,
  --   insertReplaceSupport = true,
  --   labelDetailsSupport = true,
  --   deprecatedSupport = true,
  --   commitCharactersSupport = true,
  --   tagSupport = { valueSet = { 1 } },
  --   resolveSupport = {
  --     properties = {
  --       "documentation",
  --       "detail",
  --       "additionalTextEdits",
  --     },
  --   },
  -- }

  -- lspconfig.sumneko_lua.setup {
  --   on_attach = on_attach,
  --   capabilities = capabilities,

  --   settings = {
  --     Lua = {
  --       diagnostics = {
  --         globals = { "vim" },
  --       },
  --       workspace = {
  --         library = {
  --           [vim.fn.expand "$VIMRUNTIME/lua"] = true,
  --           [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
  --         },
  --         maxPreload = 100000,
  --         preloadFileSize = 10000,
  --       },
  --     },
  --   },
  -- }

  -- lspconfig.tsserver.setup {
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  -- }

  -- lspconfig.tailwindcss.setup {
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  -- }

  -- lspconfig.golangci_lint_ls.setup {
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  -- }

  -- lspconfig.gopls.setup {
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  -- }
end

return M
