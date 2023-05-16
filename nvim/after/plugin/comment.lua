local comment = require("Comment")

local options = {
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    opleader = {
        line = '<leader>c',
        block = '<leader>b',
    }
}

comment.setup(options)
