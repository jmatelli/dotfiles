return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod" },
    { "kristijanhusak/vim-dadbod-completion" },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1
    vim.g.dbs = {
      { name = "Yaarz - DEV", url = "postgresql://postgres:postgres@localhost:5432/yaarz" },
      { name = "Yaarz - TEST", url = "postgresql://postgres:postgres@localhost:5432/yaarz_test" },
      { name = "Yaarz - E2E TEST", url = "postgresql://postgres:postgres@localhost:5432/yaarz_e2e_test" },
      {
        name = "Yaarz - PROD readonly",
        url = "postgresql://uroiekrv9tri53tnitb2:pnnqqnghv6nhu8uv4tf1bhm4pdmcqx@bu5qnmyfphejax2hicb8-postgresql.services.clever-cloud.com:6014/bu5qnmyfphejax2hicb8",
      },
      {
        name = "Yaarz - PROD",
        url = "postgresql://usykbprm1paucdwcpzhr:vh9kvQM2eJlb4rG2eqWm@bu5qnmyfphejax2hicb8-postgresql.services.clever-cloud.com:6014/bu5qnmyfphejax2hicb8",
      },
    }
  end,
  keys = {
    { "<leader>db", "<cmd>bd<cr><cmd>DBUIToggle<cr>" },
  },
}
