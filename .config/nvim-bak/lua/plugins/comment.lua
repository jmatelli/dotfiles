return {
  "echasnovski/mini.comment",
  version = "*",
  config = function()
    require("mini.comment").setup({
      options = {
        custom_commentstring = function()
          require('ts_context_commentstring').setup({})
          vim.g.skip_ts_context_commentstring_module = true
        end,
        -- mappings = {
        --  comment = '<leader>c',
        --  comment_line = '<leader>c'
        -- },
      }
    })
  end
}
