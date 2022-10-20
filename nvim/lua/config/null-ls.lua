local M = {}

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
      null_ls.builtins.diagnostics.eslint_d,
      null_ls.builtins.diagnostics.gitlint,
      null_ls.builtins.diagnostics.golangci_lint,
      null_ls.builtins.diagnostics.jsonlint,
      null_ls.builtins.diagnostics.luacheck,
      null_ls.builtins.diagnostics.markdownlint,
      null_ls.builtins.diagnostics.selene,
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
    on_attach = function(client)
      if client.resolved_capabilities.document_formatting then
        vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
      end
    end,
  }
end

return M
