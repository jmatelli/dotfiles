local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>,", "m`A,<ESC>", opts)
vim.keymap.set("n", "<leader>;", "m`A;<ESC>", opts)

-- Better indent
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Center search results
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "nzzzv", opts)
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Move line(s)
vim.keymap.set("n", "<C-k>", ":m .-2<CR>==", opts)
vim.keymap.set("n", "<C-j>", ":m .+1<CR>==", opts)
vim.keymap.set("i", "<C-k>", "<ESC>:m .-2<CR>==gi", opts)
vim.keymap.set("i", "<C-j>", "<ESC>:m .+1<CR>==gi", opts)
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", opts)
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", opts)

-- Paste over currently selected text without yankink it
vim.keymap.set("v", "p", '"_dP', opts)

-- Cancel search highlighting
vim.keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", opts)

-- New lines
vim.keymap.set("n", "<leader>o", "o<ESC>k", opts)
vim.keymap.set("n", "<leader>O", "O<ESC>j", opts)

vim.keymap.set({ "n", "v" }, "<leader>bd", "<CMD>bufdo bde!<CR><CMD>Alpha<CR>", opts)
