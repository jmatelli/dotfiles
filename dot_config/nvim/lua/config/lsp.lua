vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.diagnostic.config({
  virtual_text = { current_line = false },
})

-- Inlay hints on everywhere except TS/JS (matches previous LazyVim config's
-- exclusion list), keyed off LspAttach rather than a per-server option since
-- vtsls/gopls both support inlay hints and the exclusion is filetype-based.
local inlay_hint_excluded_filetypes = {
  typescript = true,
  javascript = true,
  typescriptreact = true,
  javascriptreact = true,
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    if client:supports_method("textDocument/inlayHint") and not inlay_hint_excluded_filetypes[vim.bo[ev.buf].filetype] then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- Nvim core's own LSP defaults use gr*-prefixed keys (grr/gri/grn/...) and
-- never bind gd - plain gd stays Vim's non-LSP local-declaration search
-- unless overridden. These three restore the previous LazyVim bindings.
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Goto References" })
vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

vim.keymap.set("n", "<S-d>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<S-u>", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
