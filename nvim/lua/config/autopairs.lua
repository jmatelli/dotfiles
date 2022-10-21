local M = {}

local file = "config/autopairs.lua"

M.setup = function()
  local status_ok_autopairs, autopairs = pcall(require, "nvim-autopairs")
  local status_ok_cmp, cmp = pcall(require, "cmp")
  local status_ok_cmp_autopairs, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')

  if not status_ok_autopairs then
    vim.notify("Could not load nvim-autopairs in " .. file)
    return
  end

  if not status_ok_cmp then
    vim.notify("Could not load cmp in " .. file)
    return
  end

  if not status_ok_cmp_autopairs then
    vim.notify("Could not load nvim-autopairs.completion.cmp in " .. file)
    return
  end

  local options = {
    fast_wrap = {},
    disable_filetype = { "TelescopePrompt", "vim" },
    map_cr = false,
  }

  autopairs.setup(options)

  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

return M
