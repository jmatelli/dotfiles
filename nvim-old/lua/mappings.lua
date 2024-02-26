local default_opts = { noremap = true, silent = true }

local utils = require("utils")

-- Center search results
utils.nnoremap("n", "nzzzv", default_opts)
utils.nnoremap("N", "Nzzzv", default_opts)
utils.nnoremap("<C-d>", "<C-d>zz")
utils.nnoremap("<C-u>", "<C-u>zz")

-- Better indent
utils.vnoremap("<", "<gv", default_opts)
utils.vnoremap(">", ">gv", default_opts)

-- Move line(s)
utils.nnoremap("<C-k>", ":m .-2<CR>==", default_opts)
utils.nnoremap("<C-j>", ":m .+1<CR>==", default_opts)
utils.inoremap("<C-k>", "<Esc>:m .-2<CR>==gi", default_opts)
utils.inoremap("<C-j>", "<Esc>:m .+1<CR>==gi", default_opts)
utils.vnoremap("<C-k>", ":m '<-2<CR>gv=gv", default_opts)
utils.vnoremap("<C-j>", ":m '>+1<CR>gv=gv", default_opts)

-- Paste over currently selected text without yanking it
utils.vnoremap("p", '"_dP', default_opts)

-- Cancel search highlighting
utils.nnoremap("<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)

-- Diagnostic
utils.nleader("e", vim.diagnostic.open_float, default_opts)
utils.nnoremap("<S-u>", vim.diagnostic.goto_prev, default_opts)
utils.nnoremap("<S-d>", vim.diagnostic.goto_next, default_opts)
utils.nleader("q", vim.diagnostic.setloclist, default_opts)
