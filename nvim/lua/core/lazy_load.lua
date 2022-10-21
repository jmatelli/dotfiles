-- taken from NvChad
local M = {}

local file = "lazy_load.lua"

local autocmd = vim.api.nvim_create_autocmd

M.lazy_load = function(tb)
  local status_ok, packer = pcall(require, "packer")

  if not status_ok then
    vim.notify("Could not load packer in " .. file)
    return
  end

  autocmd(tb.events, {
    group = vim.api.nvim_create_augroup(tb.augroup_name, {}),
    callback = function()
      if tb.condition() then
        vim.api.nvim_del_augroup_by_name(tb.augroup_name)

        if tb.plugin ~= "nvim-treesitter" then
          vim.defer_fn(function()
            packer.loader(tb.plugin)
            if tb.plugin == "nvim-lspconfig" then
              vim.cmd "silent! e %"
            end
          end, 0)
        else
          packer.loader(tb.plugin)
        end
      end
    end
  })
end

M.on_file_open = function(plugin_name)
  M.lazy_load({
    events = { "BufRead", "BufWinEnter", "BufNewFile" },
    augroup_name = "BeLazyOnFileOpen"..plugin_name,
    plugin = plugin_name,
    condition = function()
      local file = vim.fn.expand "%"
      return file ~= "NvimTree_1" and file ~= "[packer]" and file ~= ""
    end,
  })
end

return M
