local g = vim.g
local o = vim.opt

g.mapleader = " "
g.maplocalleader = " "

vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true })

g.markdown_recommended_style = 0
g.transparency = true

o.background = "dark"
o.breakindent = true -- preserve horizontal block of text
o.clipboard = "unnamedplus" -- access system clipboard
o.completeopt = "menu,menuone,noselect"
o.conceallevel = 3
o.confirm = true -- confirm to save changes when exiting buffer
o.cursorline = true -- highlight current line
o.expandtab = true -- use space instead of tabs
o.filetype = "on" -- enable filetype detection
o.formatoptions = "jcroqlnt"
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep"
o.hidden = true
o.hlsearch = true -- set highlight on search
o.ignorecase = true -- case insensitive searching unlind /C or capital in search
o.inccommand = "nosplit"
o.incsearch = true
o.laststatus = 3
-- o.list = true
-- o.listchars = { tab = "· ", trail = "·", nbsp = "·" }
o.pumblend = 10 -- popup blend
o.pumheight = 10 -- max entries in popup
o.relativenumber = true -- make relative number default
o.ruler = false
o.scrolloff = 8
o.sessionoptions = { "buffers", "curdir", "winsize" }
o.shiftround = true -- round indent to shiftwidth
o.shiftwidth = 2
o.shortmess:append("sI")
o.showmode = false
o.showtabline = 0
o.sidescrolloff = 8
o.signcolumn = "yes" -- always show sign column
o.smartcase = true -- override ignorecase if search pattern has upper case
o.smartindent = true -- auto indent on new line
o.softtabstop = 2
o.splitbelow = true -- new split below when horiazontal split
o.splitright = true -- new split on the right when vertical split
o.swapfile = false
o.syntax = "on"
o.tabstop = 2
o.timeoutlen = 300 -- time in ms to wait for a mapped sequence to complete
o.undofile = true -- save undo history
o.undolevels = 10000
o.updatetime = 250 -- decrease update time
o.whichwrap:append("<>[]hl") -- go to previous/next line with h,l,left and right when cursor reaches end/beginning of line
o.wildmode = "longest:full,full"
o.winminwidth = 5
o.wrap = true

o.foldcolumn = "1"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true

if vim.fn.has("nvim-0.9.0") == 1 then
	o.splitkeep = "screen" -- keep the text on the same screen line
	o.shortmess:append({ C = true })
end
