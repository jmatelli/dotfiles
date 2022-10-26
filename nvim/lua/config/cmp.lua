local M = {}

local file = "config/cmp.lua"

function M.setup()
  local status_ok_utils, utils = pcall(require, "core.utils")

  if not status_ok_utils then
    return vim.notify("Could not load core.utils in " .. file)
  end

  utils.load_highlights "cmp"

  local status_ok_cmp, cmp = pcall(require, "cmp")
  local status_ok_luasnip, luasnip = pcall(require, "luasnip")
  local status_ok_lspkind, lspkind = pcall(require, "lspkind")

  if not status_ok_cmp then
    return vim.notify("Could not load CMP in " .. file)
  end

  if not status_ok_luasnip then
    return vim.notify("Could not load luasnip in " .. file)
  end

  if not status_ok_lspkind then
    return vim.notify("Could not load lspkind in " .. file)
  end

  vim.opt.completeopt = "menuone,noselect"

  local function border(hl_name)
    return {
      { "╭", hl_name },
      { "─", hl_name },
      { "╮", hl_name },
      { "│", hl_name },
      { "╯", hl_name },
      { "─", hl_name },
      { "╰", hl_name },
      { "│", hl_name },
    }
  end

  cmp.setup {
    window = {
      completion = {
        border = border "CmpBorder",
        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      },
      documentation = {
        border = border "CmpDocBorder",
      },
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    formatting = {
      format = lspkind.cmp_format({
        mode = "symbol_text",
      })
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.replace,
        select = false,
      }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s", }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s", }),
    }),
    sources = {
      { name = "luasnip" },
      { name = "nvim_lsp" },
      {
        name = "buffer",
        option = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end
        }
      },
      { name = "nvim_lua" },
      { name = "path" },
      { name = 'nvim_lsp_signature_help' },
    },
  }

  cmp.setup.cmdline(':', {
    sources = {
      { name = 'cmdline' }
    }
  })

  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })
end

return M
