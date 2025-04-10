return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  lazy = true,
  opts = {
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
