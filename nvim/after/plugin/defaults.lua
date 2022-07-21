local api = vim.api
local g = vim.g
local opt = vim.opt

-- Remap leader and local leader to <Space>
api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
g.mapleader = " "
g.maplocalleader = " "

opt.termguicolors = true -- Enable colors in terminal
opt.hlsearch = true -- Set highlight on search

-- Visual settings
opt.number = true -- Make line numbers default
opt.relativenumber = true -- Make relative number default

-- More natural split
opt.splitbelow = true
opt.splitright = true

-- Searching
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true -- Case insensitive searching unless /C or capital in search
opt.smartcase = true -- Smart case

opt.timeoutlen = 300 -- Time in ms to wait for a mappaed sequence to complete
opt.updatetime = 250 -- Decrease update time
opt.signcolumn = "yes" -- Always show sign column
opt.clipboard = "unnamedplus" -- Access system clipboard
opt.showtabline = 0

-- Tabs
opt.tabstop = 4
opt.softtabstop = 0
opt.shiftwidth = 4
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
opt.laststatus = 2
opt.background = "dark"
opt.list = true
opt.listchars = { tab = "· ", trail = "·", nbsp = "·" }
opt.completeopt = { "menu", "menuone", "noselect" }

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]
