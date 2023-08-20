local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

local utils = require("core.utils")

-- Center search results
utils.nnoremap("n", "nzzzv", default_opts)
utils.nnoremap("N", "Nzzzv", default_opts)
utils.nnoremap("<C-d>", "<C-d>zz")
utils.nnoremap("<C-u>", "<C-u>zz")

-- Visual line wrap
utils.nnoremap("k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
utils.nnoremap("j", "v:count == 0 ? 'gj' : 'j'", expr_opts)

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

-- terminal
utils.tnoremap("<C-Up>", "<cmd>resize -2<CR>")
utils.tnoremap("<C-Down>", "<cmd>resize +2<CR>")
utils.tnoremap("<C-Left>", "<cmd>vertical resize -2<CR>")
utils.tnoremap("<C-Right>", "<cmd>vertical resize +2<CR>")
