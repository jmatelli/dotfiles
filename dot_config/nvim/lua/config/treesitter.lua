local parsers = {
  "go",
  "gomod",
  "gowork",
  "gosum",
  "typescript",
  "tsx",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "bash",
  "markdown",
  "markdown_inline",
  "css",
  "html",
  "yaml",
  "toml",
  "vim",
  "vimdoc",
  "query",
  "gitcommit",
  "gitignore",
  "diff",
  "dockerfile",
  "git_config",
}

require("nvim-treesitter").install(parsers)

local ts_filetypes = {
  "go",
  "gomod",
  "gowork",
  "gosum",
  "typescript",
  "typescriptreact",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "lua",
  "bash",
  "sh",
  "markdown",
  "css",
  "html",
  "yaml",
  "toml",
  "vim",
  "help",
  "gitcommit",
  "gitignore",
  "diff",
  "dockerfile",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_filetypes,
  callback = function()
    vim.treesitter.start()
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[0][0].foldmethod = "expr"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
