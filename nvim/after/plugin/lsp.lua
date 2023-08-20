local utils = require("core.utils")

local lspconfig = require("lspconfig")
local null_ls = require("null-ls")
local mason = require("mason")
local masonlsp = require("mason-lspconfig")
local mason_nullls = require("mason-null-ls")
local cmp_lsp = require("cmp_nvim_lsp")
local schemas = require("schemastore")

local getBufOpts = function(bufnr, desc)
  return { noremap = true, silent = true, buffer = bufnr, desc = desc }
end

local on_attach = function(_, bufnr)
  utils.nnoremap("K", vim.lsp.buf.hover, getBufOpts(bufnr, "Hover"))
  utils.nnoremap("gd", vim.lsp.buf.definition, getBufOpts(bufnr, "[G]o to [D]efinition"))
  utils.nnoremap("gD", vim.lsp.buf.declaration, getBufOpts(bufnr, "[G]o to [D]eclaration"))
  utils.nnoremap("gi", vim.lsp.buf.implementation, getBufOpts(bufnr, "[G]o to [I]mplementation"))
  utils.nnoremap("go", vim.lsp.buf.type_definition, getBufOpts(bufnr, "Type Definition"))
  utils.nnoremap("gr", vim.lsp.buf.references, getBufOpts(bufnr, "[G]o to [R]eference"))
  utils.nnoremap("<leader>sh", vim.lsp.buf.signature_help, getBufOpts(bufnr, "[S]ignature [H]elp"))
  utils.nnoremap("<leader>fm", function()
    vim.lsp.buf.format({ async = true })
  end, getBufOpts(bufnr, "[F]or[M]at"))
  utils.nnoremap("<leader>rn", vim.lsp.buf.rename, getBufOpts(bufnr, "[R]e[N]ame"))
end


local opts = { noremap = true, silent = true }
utils.nleader("e", vim.diagnostic.open_float, opts)
utils.nnoremap("[d", vim.diagnostic.goto_prev, opts)
utils.nnoremap("]d", vim.diagnostic.goto_next, opts)
utils.nleader("q", vim.diagnostic.setloclist, opts)

require("mason.settings").set({
  ui = {
    border = "rounded",
  }
})

local servers = {
  "bashls",
  "tsserver",
  "html",
  "eslint",
  "lua_ls",
  "gopls",
  "tailwindcss",
  "jsonls",
  "yamlls",
  -- "stylelint_lsp",
}

local capabilities = cmp_lsp.default_capabilities()

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
    },
  },
}
lspconfig.eslint.setup {
  on_attach = function(_, bufnr)
    on_attach(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
  capabilities = capabilities,
}
lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    json = {
      schemas = schemas.json.schemas(),
      validate = { enable = true },
    }
  }
}
lspconfig.yamlls.setup {
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = schemas.yaml.schemas(),
    },
  },
}

-- lspconfig.stylelint_lsp.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = { "css", "less", "scss" },
--   settings = {
--     autofixOnSave = true,
--     autofixOnFormat = true,
--     validateOnSave = false,
--     validateOnType = false,
--   }
-- }

mason.setup()
masonlsp.setup({
  ensure_installed = servers
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    local client = vim.lsp.get_active_clients({ bufnr = event.buf, name = "eslint" })[1]
    if client then
      local diag = vim.diagnostic.get(event.buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
      if #diag > 0 then
        vim.cmd("EslintFixAll")
      end
    end
  end
})

local signs = {
  { name = "DiagnosticSignError", text = "✘" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignHint", text = "" },
  { name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

-- see documentation of null-null-ls for more configuration options!
mason_nullls.setup({
  ensure_installed = { "eslint_d", "prettierd", "stylua" },
  automatic_installation = true,
  automatic_setup = true,
})
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.eslint,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.stylua,
  }
})
