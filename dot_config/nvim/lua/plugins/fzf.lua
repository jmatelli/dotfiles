return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader><leader>", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffers" },
    { "<C-P>", "<cmd>FzfLua files<cr>", desc = "Find Files (Root Dir)" },
    { "<leader>,", false },
  },
  opts = {
    file_ignore_patterns = { "node_modules", "mocks" },
  },
}
