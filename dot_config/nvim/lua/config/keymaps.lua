-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local opts = { noremap = true, silent = true }

local getOpts = function(desc)
  return vim.tbl_extend("force", opts, { desc = desc })
end

vim.keymap.set("n", "<M-o>", function()
  vim.notify("Writing file...")
  vim.cmd("update")
  vim.notify("Sourcing config...")
  vim.cmd("source")
  vim.notify("Config sourced successfully!")
end, getOpts("Update and Source Config"))

vim.keymap.set("n", "<leader>,", "m`A,<ESC>", getOpts("Add Trailing Comma"))
vim.keymap.set("n", "<leader>;", "m`A;<ESC>", getOpts("Add Trailing Semicolon"))

-- uuid generation with <c-r>=trim(system('uuidgen')) in normal or insert mode
vim.keymap.set("n", "<M-u>", "i<C-r>=trim(system('uuidgen'))<CR><esc>", getOpts("Generate UUID"))
vim.keymap.set("i", "<M-u>", "<C-r>=trim(system('uuidgen'))<CR>", getOpts("Generate UUID"))

-- vim.keymap.set("n", "<C-d>", "<C-d>zz", getOpts("Scroll Down and Center"))
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", getOpts("Scroll Up and Center"))
-- vim.keymap.set("n", "n", "nzzzv", getOpts("Next Search Result Centered"))
-- vim.keymap.set("n", "N", "Nzzzv", getOpts("Previous Search Result Centered"))

-- Better indent
vim.keymap.set("v", "<", "<gv", getOpts("Unindent Selection"))
vim.keymap.set("v", ">", ">gv", getOpts("Indent Selection"))

-- indent and unindent with <M-l> and <M-h>
vim.keymap.set("n", "<M-l>", ">>", getOpts("Indent Line"))
vim.keymap.set("n", "<M-h>", "<<", getOpts("Unindent Line"))
vim.keymap.set("v", "<M-l>", ">gv", getOpts("Indent Selection"))
vim.keymap.set("v", "<M-h>", "<gv", getOpts("Unindent Selection"))

-- Paste over currently selected text without yankink it
vim.keymap.set("v", "p", '"_dP', getOpts("Paste Over Selection Without Yanking"))

-- New lines
vim.keymap.set("n", "<leader>o", "o<ESC>k", getOpts("Open New Line Below"))
vim.keymap.set("n", "<leader>O", "O<ESC>j", getOpts("Open New Line Above"))

local function insertFullPath()
  local filepath = vim.fn.expand("%")
  vim.fn.setreg("+", filepath) -- write to clippoard
end

vim.keymap.set("n", "<leader>yc", insertFullPath, { noremap = true, silent = true })
