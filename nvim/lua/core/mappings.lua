local default_opts = { noremap = true, silent = true }

local utils = require("core.utils")

-- Center search results
utils.nnoremap("n", "nzzzv", default_opts)
utils.nnoremap("N", "Nzzzv", default_opts)
utils.nnoremap("<C-d>", "<C-d>zz")
utils.nnoremap("<C-u>", "<C-u>zz")

-- Better indent
utils.vnoremap("<", "<gv", default_opts)
utils.vnoremap(">", ">gv", default_opts)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Move line(s)
utils.nnoremap("<S-Up>", ":m .-2<CR>==", default_opts)
utils.nnoremap("<S-Down>", ":m .+1<CR>==", default_opts)
utils.inoremap("<S-Up>", "<Esc>:m .-2<CR>==gi", default_opts)
utils.inoremap("<S-Down>", "<Esc>:m .+1<CR>==gi", default_opts)
utils.vnoremap("<S-Up>", ":m '<-2<CR>gv=gv", default_opts)
utils.vnoremap("<S-Down>", ":m '>+1<CR>gv=gv", default_opts)

-- Paste over currently selected text without yanking it
utils.vnoremap("p", '"_dP', default_opts)

-- Cancel search highlighting
utils.nnoremap("<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)

utils.nnoremap("<C-Up>", ":resize -2<CR>")
utils.nnoremap("<C-Down>", ":resize +2<CR>")
utils.nnoremap("<C-Left>", ":vertical resize -2<CR>")
utils.nnoremap("<C-Right>", ":vertical resize +2<CR>")

-- Terminal
utils.tnoremap("<C-Up>", "<cmd>resize -2<CR>")
utils.tnoremap("<C-Down>", "<cmd>resize +2<CR>")
utils.tnoremap("<C-Left>", "<cmd>vertical resize -2<CR>")
utils.tnoremap("<C-Right>", "<cmd>vertical resize +2<CR>")

-- Diagnostic
utils.nleader("e", vim.diagnostic.open_float, default_opts)
utils.nnoremap("<S-u>", vim.diagnostic.goto_prev, default_opts)
utils.nnoremap("<S-d>", vim.diagnostic.goto_next, default_opts)
utils.nleader("q", vim.diagnostic.setloclist, default_opts)
