vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4

vim.cmd [[
    iabbrev <buffer> ife$ if err != nil {<CR>return<CR>}<Esc><Up>A
    iabbrev <buffer> iff$ if err != nil {<CR>log.Fatal(err)<CR>}<CR>
]]
