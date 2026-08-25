return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  lazy = true,
  enabled = false,
  opts = {
    copilot_node_command = vim.fn.expand("$HOME") .. "/.nvm/versions/node/v22.21.1/bin/node",
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = "<M-y>",
        next = "<M-l>",
        prev = "<M-h>",
        dismiss = "<M-x>",
      },
    },
  },
}
