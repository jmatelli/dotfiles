local luasnip = require("luasnip")
local loaders = require("luasnip.loaders.from_vscode")

luasnip.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
})
loaders.lazy_load { paths = vim.g.luasnippets_path or "" }
loaders.lazy_load()

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if
      luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
      and not luasnip.session.jump_active
    then
      luasnip.unlink_current()
    end
  end,
})
