local utils = require("core.utils")

local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  local nmap = function(keys, mapping)
    utils.nnoremap(keys, mapping, bufopts)
  end
  nmap("K", "<cmd>lua vim.lsp.buf.hover()<cr>")
  nmap("gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
  nmap("gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
  nmap("gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")
  nmap("go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
  nmap("gr", "<cmd>lua vim.lsp.buf.references()<cr>")
  nmap("<leader>sh", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
  nmap("<leader>fm", "<cmd>lua vim.lsp.buf.formatting()<cr>")
  nmap("<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>")
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

local lsp = require("lsp-zero")

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
  "bashls",
  "tsserver",
  "eslint",
  "sumneko_lua",
  "gopls",
})
lsp.nvim_workspace()
lsp.on_attach(on_attach)
lsp.setup()
