local utils = require("core.utils")

local filter = function(arr, fn)
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

local filterReactDTS = function(value)
  return string.match(value.filename, '%.d.ts') == nil
end

local on_list = function(options)
  local items = options.items
  if #items > 1 then
    items = filter(items, filterReactDTS)
  end

  vim.fn.setqflist({}, ' ', { title = options.title, items = items, context = options.context })
  vim.api.nvim_command('cfirst') -- or maybe you want 'copen' instead of 'cfirst'
end

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
  utils.nnoremap("gd", function() vim.lsp.buf.definition({ on_list = on_list }) end, getBufOpts("[G]o to [D]efinition"))
  utils.nnoremap("gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", getBufOpts("[G]o to [D]eclaration"))
  utils.nnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", getBufOpts("[G]o to [I]mplementation"))
  utils.nnoremap("go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", getBufOpts())
  utils.nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<cr>", getBufOpts("[G]o to [R]eference"))
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
local null_ls = require("null-ls")

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
lsp.setup_nvim_cmp({
  preselect = "none",
  completion = {
    completeopt = "menu,menuone,noinsert,noselect",
  },
})
lsp.nvim_workspace()
lsp.on_attach(on_attach)
-- lsp.configure('tsserver', {
--   on_attach = function(client, bufnr)
--     on_attach(client, bufnr)
--     local au_lsp = vim.api.nvim_create_augroup("eslint_lsp", { clear = true })
--     vim.api.nvim_create_autocmd("BufWritePre", {
--       pattern = "*",
--       callback = function()
--         vim.cmd "LspZeroFormat"
--       end,
--       group = au_lsp,
--     })
--   end,
-- })
lsp.configure('stylelint_lsp', {
  filetypes = { "css", "less", "scss" },
})

lsp.setup()

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
local mason_nullls = require("mason-null-ls")
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
