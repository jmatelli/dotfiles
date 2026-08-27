local opts = { noremap = true, silent = true }

local function getOpts(desc)
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

-- Better indent
vim.keymap.set("v", "<", "<gv", getOpts("Unindent Selection"))
vim.keymap.set("v", ">", ">gv", getOpts("Indent Selection"))

-- indent and unindent with <M-l> and <M-h>
vim.keymap.set("n", "<M-l>", ">>", getOpts("Indent Line"))
vim.keymap.set("n", "<M-h>", "<<", getOpts("Unindent Line"))
vim.keymap.set("v", "<M-l>", ">gv", getOpts("Indent Selection"))
vim.keymap.set("v", "<M-h>", "<gv", getOpts("Unindent Selection"))

-- Paste over currently selected text without yanking it
vim.keymap.set("v", "p", '"_dP', getOpts("Paste Over Selection Without Yanking"))

-- Move lines up/down with <M-j>/<M-k> (Option+J/K on mac)
vim.keymap.set("n", "<M-j>", "<cmd>execute 'move .+' . v:count1<cr>==", getOpts("Move Line Down"))
vim.keymap.set("n", "<M-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", getOpts("Move Line Up"))
vim.keymap.set("i", "<M-j>", "<esc><cmd>m .+1<cr>==gi", getOpts("Move Line Down"))
vim.keymap.set("i", "<M-k>", "<esc><cmd>m .-2<cr>==gi", getOpts("Move Line Up"))
vim.keymap.set("v", "<M-j>", ":m '>+1<cr>gv=gv", getOpts("Move Selection Down"))
vim.keymap.set("v", "<M-k>", ":m '<-2<cr>gv=gv", getOpts("Move Selection Up"))

-- New lines
vim.keymap.set("n", "<leader>o", "o<ESC>k", getOpts("Open New Line Below"))
vim.keymap.set("n", "<leader>O", "O<ESC>j", getOpts("Open New Line Above"))

local function insertFullPath()
  local filepath = vim.fn.expand("%")
  vim.fn.setreg("+", filepath) -- write to clipboard
end

vim.keymap.set("n", "<leader>yc", insertFullPath, { noremap = true, silent = true })
