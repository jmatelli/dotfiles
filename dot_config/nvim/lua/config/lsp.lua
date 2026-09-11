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

    -- vtsls' textDocument/definition on an imported symbol resolves to the
    -- import statement (its own local "definition"), not the original
    -- declaration. typescript.goToSourceDefinition is vtsls' custom command
    -- for VS Code's "Go to Source Definition", which follows the import
    -- through to the real declaration, even in another file.
    if client.name == "vtsls" then
      vim.keymap.set("n", "gd", function()
        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
        client:exec_cmd({
          command = "typescript.goToSourceDefinition",
          arguments = { params.textDocument.uri, params.position },
        }, { bufnr = ev.buf }, function(err, result)
          if err or not result or vim.tbl_isempty(result) then
            vim.lsp.buf.definition()
            return
          end
          vim.lsp.util.show_document(result[1], client.offset_encoding, { reuse_win = true, focus = true })
        end)
      end, { buffer = ev.buf, desc = "Goto Source Definition" })
    end

    -- Go to Implementation surfaces mock implementations (mocks/,
    -- servicemocks, etc.) alongside the real one, which is rarely what you
    -- want - filter them out, falling back to the unfiltered list only if
    -- every result was a mock.
    if client.name == "gopls" then
      vim.keymap.set("n", "gI", function()
        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
        client:request("textDocument/implementation", params, function(err, result)
          if err then
            vim.notify(err.message, vim.log.levels.WARN)
            return
          end
          if not result or vim.tbl_isempty(result) then
            vim.notify("No locations found", vim.log.levels.INFO)
            return
          end

          local locations = vim.islist(result) and result or { result }
          local filtered = vim.tbl_filter(function(loc)
            local uri = loc.uri or loc.targetUri or ""
            return not uri:lower():find("mock", 1, true)
          end, locations)
          local items = vim.tbl_isempty(filtered) and locations or filtered

          if #items == 1 then
            vim.lsp.util.show_document(items[1], client.offset_encoding, { reuse_win = true, focus = true })
            return
          end

          vim.fn.setqflist({}, " ", {
            title = "LSP locations",
            items = vim.lsp.util.locations_to_items(items, client.offset_encoding),
          })
          require("fzf-lua").quickfix()
        end, ev.buf)
      end, { buffer = ev.buf, desc = "Goto Implementation (skip mocks)" })
    end
  end,
})

-- Nvim core's own LSP defaults use gr*-prefixed keys (grr/gri/grn/...) and
-- never bind gd - plain gd stays Vim's non-LSP local-declaration search
-- unless overridden. These three restore the previous LazyVim bindings.
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
vim.keymap.set("n", "gr", function()
  require("fzf-lua").lsp_references({ jump1 = true })
end, { desc = "Goto References" })
vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- opts.float was deprecated in favor of opts.on_jump (nvim#diagnostic.lua);
-- this reproduces the same "open a float after jumping" behavior explicitly.
local function open_float_on_jump(_, bufnr)
  vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
end

vim.keymap.set("n", "<S-d>", function()
  vim.diagnostic.jump({ count = 1, on_jump = open_float_on_jump })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<S-u>", function()
  vim.diagnostic.jump({ count = -1, on_jump = open_float_on_jump })
end, { desc = "Previous diagnostic" })
