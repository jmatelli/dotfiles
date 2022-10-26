local M = {}

local keymap = vim.keymap.set

M.nnoremap = function(lhs, rhs, options)
  keymap('n', lhs, rhs, options or { silent = true })
end
M.vnoremap = function(lhs, rhs, options)
  keymap('v', lhs, rhs, options or { silent = true })
end
M.nleader = function(lhs, rhs, options)
  keymap('n', '<leader>' .. lhs, rhs, options or { silent = true })
end
M.vleader = function(lhs, rhs, options)
  keymap('x', '<leader>' .. lhs, rhs, options or { silent = true })
end

M.setHl = function(hl, val)
  vim.api.nvim_set_hl(0, hl, val)
end

M.load_highlights = function(name)
  local status_ok, group = pcall(require, "core.highlights." .. name)

  if not status_ok then
    vim.notify("There are no highlight files for " .. name, vim.log.levels.ERROR)
    return
  end

  for hl, colors in pairs(group) do
    vim.api.nvim_set_hl(0, hl, colors)
  end
end

return M
