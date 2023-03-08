local g = vim.g
local opt = vim.opt

-- Remap leader and local leader to <Space>
g.mapleader = " "

opt.termguicolors = true -- Enable colors in terminal
opt.hlsearch = true -- Set highlight on search

-- Visual settings
opt.number = true -- Make line numbers default
opt.relativenumber = true -- Make relative number default
opt.ruler = false

-- More natural split
opt.splitbelow = true
opt.splitright = true

-- Searching
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true -- Case insensitive searching unless /C or capital in search
opt.smartcase = true -- Smart case

-- Folds
-- opt.foldmethod = "expr"
-- opt.foldcolumn = "2"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldlevel = 99

opt.timeoutlen = 300 -- Time in ms to wait for a mappaed sequence to complete
opt.updatetime = 250 -- Decrease update time
opt.signcolumn = "yes" -- Always show sign column
opt.clipboard = "unnamedplus" -- Access system clipboard
opt.cul = true
opt.showtabline = 0

-- Tabs
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.expandtab = true

-- Enable hidden buffers
opt.hidden = true

-- Misc
opt.mouse = "a" -- Enable mouse mode
opt.breakindent = true -- Enable break indent
opt.undofile = true -- Save undo history
opt.swapfile = false
opt.filetype = "on"
opt.syntax = "on"
opt.scrolloff = 8
opt.background = "dark"
opt.list = true
opt.listchars = { tab = "· ", trail = "·", nbsp = "·" }
opt.completeopt = "menu,menuone,noselect"

opt.laststatus = 3
opt.showmode = false

-- disable nvim intro
opt.shortmess:append "sI"

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

vim.g.transparency = true

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Write and Quit
vim.cmd [[
  command! -bang -range=% -complete=file -nargs=* W <line1>,<line2>write<bang> <args>
  command! -bang Q quit<bang>
]]

