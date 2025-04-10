-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local opts = { noremap = true, silent = true }

local getOpts = function(desc)
  return vim.tbl_extend("force", opts, { desc = desc })
end

vim.keymap.set("n", "<leader>,", "m`A,<ESC>", getOpts("Add Trailing Comma"))
vim.keymap.set("n", "<leader>;", "m`A;<ESC>", getOpts("Add Trailing Semicolon"))

-- uuid generation with <c-r>=trim(system('uuidgen')) in normal or insert mode
vim.keymap.set("n", "<M-u>", "i<C-r>=trim(system('uuidgen'))<CR><esc>", getOpts("Generate UUID"))
vim.keymap.set("i", "<M-u>", "<C-r>=trim(system('uuidgen'))<CR>", getOpts("Generate UUID"))
