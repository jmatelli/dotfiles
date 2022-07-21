local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

local function nnoremap(lhs, rhs, options)
    keymap('n', lhs, rhs, options or { silent = true })
end
local function nleader(lhs, rhs, options)
    keymap('n', '<leader>'..lhs, rhs, options or { silent = true })
end
local function vleader(lhs, rhs, options)
    keymap('x', '<leader>'..lhs, rhs, options or { silent = true })
end

-- Center search results
nnoremap("n", "nzz", default_opts)
nnoremap("N", "Nzz", default_opts)

-- Visual line wrap
nnoremap("k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
nnoremap("j", "v:count == 0 ? 'gj' : 'j'", expr_opts)

-- Better indent
keymap("v", "<", "<gv", default_opts)
keymap("v", ">", ">gv", default_opts)

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dP', default_opts)

-- Switch buffer
nnoremap("<S-h>", ":bprevious<CR>", default_opts)
nnoremap("<S-j>", ":bnext<CR>", default_opts)

-- Cancel search highlighting
nnoremap("<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)
nleader("noh", ":nohlsearch<Bar>:echo<CR>", default_opts)

-- Telescope
nleader("<leader>", ":Telescope buffers<CR>", default_opts)
nnoremap("<C-p>", ":Telescope find_files<CR>", default_opts)

-- Comments
nleader("c", "gcc", { remap = true })
vleader("c", "gc", { remap = true })

-- colons & semicolons
nleader(",", "m`A,<Esc>``", default_opts)
nleader(";", "m`A;<Esc>``", default_opts)

-- Insert line above/below
nleader("o", "o<Esc>k", default_opts)
nleader("O", "O<Esc>k", default_opts)

-- Tree
nnoremap("<F2>", ":NvimTreeToggle<CR>", default_opts)
nnoremap("<F3>", ":NvimTreeFindFile<CR>", default_opts)
