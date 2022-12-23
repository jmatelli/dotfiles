local utils = require("core.utils")

local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  local getBufOpts = function(desc)
    if desc then
      return { noremap = true, silent = true, buffer = bufnr, desc = desc }
    end
    return { noremap = true, silent = true, buffer = bufnr }
  end
  utils.nnoremap("K", "<cmd>lua vim.lsp.buf.hover()<cr>", getBufOpts())
  utils.nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<cr>", getBufOpts())
  utils.nnoremap("gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", getBufOpts())
  utils.nnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", getBufOpts())
  utils.nnoremap("go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", getBufOpts())
  utils.nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<cr>", getBufOpts())
  utils.nnoremap("<leader>sh", "<cmd>lua vim.lsp.buf.signature_help()<cr>", getBufOpts("[S]ignature [H]elp"))
  utils.nnoremap("<leader>fm", "<cmd>lua vim.lsp.buf.formatting()<cr>", getBufOpts("[F]or[M]atting"))
  utils.nnoremap("<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", getBufOpts("[R]e[N]ame"))
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
  "jsonls",
  "html",
  "cssls",
  "cssmodules_ls",
  "eslint",
  "sumneko_lua",
  "gopls",
  "prosemd_lsp",
  "dockerls",
  "elmls",
  "tailwindcss",
  "stylelint_lsp",
})
lsp.nvim_workspace()
lsp.on_attach(on_attach)
lsp.setup()
