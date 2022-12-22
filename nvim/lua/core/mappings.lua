local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

local utils = require("core.utils")

-- Center search results
utils.nnoremap("n", "nzz", default_opts)
utils.nnoremap("N", "Nzz", default_opts)

-- Visual line wrap
utils.nnoremap("k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
utils.nnoremap("j", "v:count == 0 ? 'gj' : 'j'", expr_opts)

-- Better indent
utils.vnoremap("<", "<gv", default_opts)
utils.vnoremap(">", ">gv", default_opts)

-- Paste over currently selected text without yanking it
utils.vnoremap("p", '"_dP', default_opts)

-- Cancel search highlighting
utils.nnoremap("<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)

-- Comments
utils.nleader("c", "gcc", { remap = true })
utils.vleader("c", "gc", { remap = true })

-- Insert line above/below
utils.nleader("o", "o<Esc>k", default_opts)
utils.nleader("O", "O<Esc>k", default_opts)
