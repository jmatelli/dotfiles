local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

local utils = require("core.utils")

local M = {}

M.general = function()
  -- Center search results
  utils.nnoremap("n", "nzz", default_opts)
  utils.nnoremap("N", "Nzz", default_opts)

  -- Visual line wrap
  utils.nnoremap("k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
  utils.nnoremap("j", "v:count == 0 ? 'gj' : 'j'", expr_opts)

  -- Better indent
  utils.vnoremap("<", "<gv", default_opts)
  utils.vnoremap(">", ">gv", default_opts)

  -- Paste over currently selected text without yanking it
  utils.vnoremap("p", '"_dP', default_opts)

  -- Cancel search highlighting
  utils.nnoremap("<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)
  utils.nleader("noh", ":nohlsearch<Bar>:echo<CR>", default_opts)

  -- Telescope
  utils.nleader("<leader>", ":Telescope buffers<CR>", default_opts)
  utils.nnoremap("<C-p>", "<cmd>lua require'config.telescope'.project_files()<cr>", default_opts)

  -- Comments
  utils.nleader("c", "gcc", { remap = true })
  utils.vleader("c", "gc", { remap = true })

  -- Insert line above/below
  utils.nleader("o", "o<Esc>k", default_opts)
  utils.nleader("O", "O<Esc>k", default_opts)

  -- Tree
  utils.nnoremap("<F2>", ":NvimTreeToggle<CR>", default_opts)
  utils.nnoremap("<F3>", ":NvimTreeFindFile<CR>", default_opts)
end

M.lspconfig = function(bufnr)
  -- Mappings
  -- See `:h vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  local setMap = function(keys, mapping)
    utils.nnoremap(keys, mapping, bufopts)
  end
  setMap("K", "<cmd>lua vim.lsp.buf.hover()<cr>")
  setMap("gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
  setMap("gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
  setMap("gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")
  setMap("go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
  setMap("gr", "<cmd>lua vim.lsp.buf.references()<cr>")
  setMap("<leader>sh", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
  setMap("<leader>fm", "<cmd>lua vim.lsp.buf.formatting()<cr>")
  setMap("<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>")
  setMap("<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>")
end

M.diagnostic = function()
  local opts = { noremap = true, silent = true }
  utils.nleader("e", vim.diagnostic.open_float, opts)
  utils.nnoremap("[d", vim.diagnostic.goto_prev, opts)
  utils.nnoremap("]d", vim.diagnostic.goto_next, opts)
  utils.nleader("q", vim.diagnostic.setloclist, opts)
end

return M
