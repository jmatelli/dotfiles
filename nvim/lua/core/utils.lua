local M = {}

local keymap = vim.keymap.set

M.nnoremap = function(lhs, rhs, options)
  keymap('n', lhs, rhs, options or { silent = true })
end
M.vnoremap = function(lhs, rhs, options)
  keymap('v', lhs, rhs, options or { silent = true })
end
M.tnoremap = function(lhs, rhs, options)
  keymap('t', lhs, rhs, options or { silent = true })
end
M.nleader = function(lhs, rhs, options)
  keymap('n', '<leader>' .. lhs, rhs, options or { silent = true })
end
M.vleader = function(lhs, rhs, options)
  keymap('x', '<leader>' .. lhs, rhs, options or { silent = true })
end

return M
