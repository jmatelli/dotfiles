local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.filetype.add({
	extension = {
		mdx = "mdx",
	},
})

require("options")
require("mappings")
require("commands")
require("lazy").setup("plugins", {
	change_detection = {
		enabled = true,
		notify = false,
	},
})
