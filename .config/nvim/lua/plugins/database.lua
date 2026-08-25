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
    vim.o.previewheight = 30
    local local_ip = vim.env.LOCAL_IP
    local urlprefix = "postgresql://postgres:postgres@" .. local_ip .. ":5432/"

    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1

    local stg_read_url = vim.env.YAARZ_READONLY_STG_DB_URL
    local stg_write_url = vim.env.YAARZ_STG_DB_URL
    local prod_read_url = vim.env.YAARZ_PROD_READONLY_DB_URL
    local prod_write_url = vim.env.YAARZ_PROD_DB_URL

    vim.g.dbs = {
      { name = "Yaarz - DEV", url = urlprefix .. "yaarz" },
      { name = "Yaarz - TEST", url = urlprefix .. "yaarz_test" },
      { name = "Yaarz - E2E TEST", url = urlprefix .. "yaarz_e2e_test" },
      { name = "Yaarz - STG readonly", url = stg_read_url },
      { name = "Yaarz - STG", url = stg_write_url },
      { name = "Yaarz - PROD readonly", url = prod_read_url },
      { name = "Yaarz - PROD", url = prod_write_url },
      {
        name = "Metabase",
        url = "postgresql://***REMOVED***:***REMOVED***@***REMOVED***/***REMOVED***",
      },
    }
  end,
  keys = {
    { "<leader>D", "<cmd>bd<cr><cmd>DBUIToggle<cr>" },
  },
}
