local M = {}

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      -- apply whatever logic you want (in this example, we'll only use null-ls)
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  })
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- add to your shared on_attach callback
local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end
end

function M.setup()
  local present, null_ls = pcall(require, "null-ls")
  if not present then return end

  null_ls.setup {
    debug = false,
    sources = {
      -- code actions
      null_ls.builtins.code_actions.eslint_d,
      null_ls.builtins.code_actions.refactoring,

      -- diagnostics
      null_ls.builtins.diagnostics.eslint_d.with({
        -- ignore prettier warnings from eslint-plugin-prettier
        filter = function(diagnostic)
          return diagnostic.code ~= "prettier/prettier"
        end,
      }),
      null_ls.builtins.diagnostics.gitlint,
      null_ls.builtins.diagnostics.golangci_lint,
      null_ls.builtins.diagnostics.jsonlint,
      null_ls.builtins.diagnostics.luacheck.with({
        extra_args = { "--globals", "vim" }
      }),
      null_ls.builtins.diagnostics.markdownlint,
      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.diagnostics.stylelint,
      null_ls.builtins.diagnostics.tidy,
      null_ls.builtins.diagnostics.todo_comments,
      null_ls.builtins.diagnostics.tsc,

      -- formatting
      null_ls.builtins.formatting.elm_format,
      null_ls.builtins.formatting.eslint_d,
      null_ls.builtins.formatting.gofmt,
      null_ls.builtins.formatting.goimports,
      null_ls.builtins.formatting.jq,
      null_ls.builtins.formatting.json_tool,
      null_ls.builtins.formatting.lua_format,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.stylelint,
      null_ls.builtins.formatting.tidy,

      -- hover
      null_ls.builtins.hover.printenv,

      -- completion
      null_ls.builtins.completion.luasnip,
    },
    on_attach = on_attach,
  }
end

return M
