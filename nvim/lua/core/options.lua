local g = vim.g
local opt = vim.opt

-- Remap leader and local leader to <Space>
g.mapleader = " "
g.maplocalleader = " "

opt.autowrite = true
opt.background = "dark"
opt.breakindent = true -- Enable break indent
opt.clipboard = "unnamedplus" -- Access system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3
opt.confirm = true -- confirm to save changes when exiting buffer
opt.cursorline = true -- highlight current line
opt.expandtab = true -- use space instead of tabs
opt.filetype = "on"
opt.formatoptions = "jcroqlnt" --tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.hidden = true
opt.hlsearch = true -- Set highlight on search
opt.ignorecase = true -- Case insensitive searching unless /C or capital in search
opt.inccommand = "nosplit"
opt.incsearch = true
opt.laststatus = 3
opt.list = true
opt.listchars = { tab = "· ", trail = "·", nbsp = "·" }
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Make line numbers default
opt.pumblend = 10 -- popup blend
opt.pumheight = 10 -- max entries in popup
opt.relativenumber = true -- Make relative number default
opt.ruler = false
opt.scrolloff = 8
opt.sessionoptions = { "buffers", "curdir", "winsize" }
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append "sI"
opt.showmode = false
opt.showtabline = 0
opt.sidescrolloff = 8
opt.signcolumn = "yes" -- Always show sign column
opt.smartcase = true -- Smart case
opt.smartindent = true
opt.softtabstop = 2
opt.spelllang = { "en" }
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.syntax = "on"
opt.tabstop = 2
opt.termguicolors = true -- Enable colors in terminal
opt.timeoutlen = 300 -- Time in ms to wait for a mappaed sequence to complete
opt.undofile = true -- Save undo history
opt.undolevels = 10000
opt.updatetime = 250 -- Decrease update time
-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.wrap = true

if vim.fn.has("nvim-0.9.0") == 1 then
  opt.splitkeep = "screen"
  opt.shortmess:append({ C = true })
end

-- fix markdown indentation settings
g.markdowm_recommended_style = 0
g.transparency = true

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Write and Quit and BufDelete
vim.cmd [[
  command! -bang -range=% -complete=file -nargs=* W <line1>,<line2>write<bang> <args>
  command! -bang Q quit<bang>
  command! -bang Bd bde<bang>
  command! -bang BD bde<bang>
]]
