local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>,", "m`A,<ESC>", opts)
vim.keymap.set("n", "<leader>;", "m`A;<ESC>", opts)

-- Better indent
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Center search results
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Paste over currently selected text without yankink it
vim.keymap.set("v", "p", '"_dP', opts)

-- Cancel search highlighting
vim.keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", opts)

-- New lines
vim.keymap.set("n", "<leader>o", "o<ESC>k", opts)
vim.keymap.set("n", "<leader>O", "O<ESC>j", opts)

vim.keymap.set("n", "<leader>bd", "<CMD>bd<CR>", vim.tbl_extend("force", opts, { desc = "Delete buffer" }))
vim.keymap.set("n", "<leader>bD", "<CMD>bufdo bd!<CR><CMD>Alpha<CR>",
    vim.tbl_extend("force", opts, { desc = "Delete all buffers" }))

-- uuid generation with <c-r>=trim(system('uuidgen')) in normal or insert mode
vim.keymap.set("n", "<M-u>", "i<C-r>=trim(system('uuidgen'))<CR><esc>", opts)
vim.keymap.set("i", "<M-u>", "<C-r>=trim(system('uuidgen'))<CR>", opts)
