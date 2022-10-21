local M = {}

local utils = require("core.utils")
local colors = require("core.colors").dracula

local on_attach = function(_, bufnr)
  -- Mappings
  -- See `:h vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  local setMap = function(keys, mapping)
    utils.nnoremap(keys, mapping, bufopts)
  end
  setMap("gD", function()
    vim.lsp.buf.declaration()
  end)
  setMap("gd", function()
    -- if vim.fn.exists(":Telescope") then
    --   vim.cmd "Telescope lsp_definitions"
    -- else
    vim.lsp.buf.definition()
    -- end
  end)
  setMap("gr", function()
    -- if vim.fn.exists(":Telescope") then
    --     vim.cmd "Telescope lsp_references"
    -- else
    vim.lsp.buf.references()
    -- end
  end)
  setMap("gi", function()
    -- if vim.fn.exists(":Telescope") then
    --     vim.cmd "Telescope lsp_implementations"
    -- else
    vim.lsp.buf.implementation()
    -- end
  end)
  setMap("K", function()
    vim.lsp.buf.hover()
  end)
  setMap("<leader>sh", function()
    vim.lsp.buf.signature_help()
  end)
  setMap("<leader>wa", function()
    vim.lsp.buf.add_workspace_folder()
  end)
  setMap("<leader>wr", function()
    vim.lsp.buf.remove_workspace_folder()
  end)
  setMap("<leader>fm", function()
    vim.lsp.buf.formatting()
  end)
  setMap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end)
  setMap("<leader>D", function()
    vim.lsp.buf.type_definition()
  end)
  setMap("<leader>rn", function()
    vim.lsp.buf.rename()
  end)
  setMap("<leader>ca", function()
    vim.lsp.buf.code_action()
  end)
end

M.cmds = {
  "LspInfo",
  "LspStart",
  "LspRestart",
  "LspStop",
  "LspInstall",
  "LspUnInstall",
  "LspUnInstallAll",
  "LspInstall",
  "LspInstallInfo",
  "LspInstallLog",
  "LspLog",
  "LspPrintInstalled",
}

M.setup = function()
  local opts = { noremap = true, silent = true }
  utils.nleader("e", vim.diagnostic.open_float, opts)
  utils.nnoremap("[d", vim.diagnostic.goto_prev, opts)
  utils.nnoremap("]d", vim.diagnostic.goto_next, opts)
  utils.nleader("q", vim.diagnostic.setloclist, opts)

  utils.setHl("DiagnosticError", { fg = colors.red })
  utils.setHl("DiagnosticWarn", { fg = colors.orange })
  utils.setHl("DiagnosticInfo", { fg = colors.blue })
  utils.setHl("DiagnosticHint", { fg = colors.purple })

  vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "DiagnosticSignError" })
  vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
  vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
  vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharacterSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      },
    },
  }

  require("lspconfig")["sumneko_lua"].setup {
    on_attach = on_attach,
    capabilities = capabilities,

    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  }

  require("lspconfig")["tsserver"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", 'javascriptreact' },
    javascript = {
      format = {
        semicolons = "insert",
      },
    },
    typescript = {
      format = {
        semicolons = "insert",
      },
    },
  }
  require("lspconfig")["tailwindcss"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "css", "html", "typescript", "typescriptreact", "javascript", "javascriptreact" },
  }
end

return M
