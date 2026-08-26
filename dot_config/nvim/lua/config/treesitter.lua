local parsers = {
  "go",
  "gomod",
  "gowork",
  "gosum",
  "gotmpl",
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
  "gotmpl",
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

require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

local select = require("nvim-treesitter-textobjects.select")
local move = require("nvim-treesitter-textobjects.move")

local textobjects = {
  ["f"] = { outer = "@function.outer", inner = "@function.inner" },
  ["c"] = { outer = "@class.outer", inner = "@class.inner" },
  ["a"] = { outer = "@parameter.outer", inner = "@parameter.inner" },
}

for key, obj in pairs(textobjects) do
  vim.keymap.set({ "x", "o" }, "a" .. key, function()
    select.select_textobject(obj.outer, "textobjects")
  end, { desc = "Select around " .. obj.outer })
  vim.keymap.set({ "x", "o" }, "i" .. key, function()
    select.select_textobject(obj.inner, "textobjects")
  end, { desc = "Select inner " .. obj.inner })
end

local moves = {
  ["]f"] = { "goto_next_start", "@function.outer" },
  ["]c"] = { "goto_next_start", "@class.outer" },
  ["[f"] = { "goto_previous_start", "@function.outer" },
  ["[c"] = { "goto_previous_start", "@class.outer" },
}

for key, spec in pairs(moves) do
  vim.keymap.set({ "n", "x", "o" }, key, function()
    move[spec[1]](spec[2], "textobjects")
  end, { desc = key .. " " .. spec[2] })
end
