local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

vim.cmd([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])

vim.cmd([[
  command! -bang -range=% -complete=file -nargs=* W <line1>,<line2>write<bang> <args>
  command! -bang Q quit<bang>
  command! -bang Bd bde<bang>
  command! -bang BD bde<bang>
]])

-- hide statusline on Alpha
autocmd("FileType", {
	pattern = "alpha",
	callback = function()
		vim.o.laststatus = 0
	end,
})
-- reset laststatus
autocmd("BufUnload", {
	buffer = 0,
	callback = function()
		vim.o.laststatus = 3
	end,
})

autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.arb",
	command = "set filetype=json",
})

autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { ".env", ".env*" },
	command = "set filetype=sh",
})

autocmd("BufEnter", {
	pattern = { ".env", ".env*" },
	group = augroup("__env", { clear = true }),
	callback = function(args)
		vim.diagnostic.disable(args.buf)
	end,
})
