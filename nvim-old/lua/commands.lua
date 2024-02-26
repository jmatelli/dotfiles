local autocmd = vim.api.nvim_create_autocmd

-- Disable statusline in dashboard
autocmd("FileType", {
  pattern = "alpha",
  callback = function() vim.opt.laststatus = 0 end,
})

autocmd("BufUnload", {
  buffer = 0,
  callback = function() vim.opt.laststatus = 3 end,
})

-- Don't auto commenting new lines
autocmd("BufEnter", {
  pattern = "*",
  command = "set fo-=c fo-=r fo-=o",
})

autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "Podfile", "*.podsec" },
  command = "set filetype=ruby",
})

-- Set Flutter .arb files syntax to JSON
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.arb" },
  command = "set filetype=json",
})

-- Terminal settings:
---------------------

-- Open a Terminal on the right tab
autocmd("CmdlineEnter", {
  command = "command! Term :botright vsplit term://$SHELL",
})

-- Enter insert mode when switching to terminal
autocmd("TermOpen", {
  command = "setlocal listchars= nonumber norelativenumber nocursorline",
})

autocmd("TermOpen", {
  pattern = "",
  command = "startinsert",
})

-- Close terminal buffer on process exit
autocmd("BufLeave", {
  pattern = "term://*",
  command = "stopinsert",
})

local group = vim.api.nvim_create_augroup("__env", {clear=true})
autocmd("BufEnter", {
  pattern = {".env", ".env*"},
  group = group,
  callback = function(args)
    vim.diagnostic.disable(args.buf)
  end
})

autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { ".env", ".env*" },
  command = "set filetype=sh",
})
