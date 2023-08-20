local comment = require("mini.comment")

comment.setup({
  options = {
    custom_commentstring = function()
      return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
    end,
  },
  mappings = {
    comment = '<leader>c',
    comment_line = '<leader>c'
  },
})
