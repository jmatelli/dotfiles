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
    local local_ip = vim.env.LOCAL_IP
    local urlprefix = "postgresql://postgres:postgres@" .. local_ip .. ":5432/"

    local yaarzStg = {
      readonly = {
        username = vim.env.YAARZ_READONLY_STG_DB_USERNAME,
        password = vim.env.YAARZ_READONLY_STG_DB_PASSWORD,
      },
      write = {
        username = vim.env.YAARZ_STG_DB_USERNAME,
        password = vim.env.YAARZ_STG_DB_PASSWORD,
      },
    }

    local yaarzProd = {
      readonly = {
        username = vim.env.YAARZ_READONLY_STG_DB_USERNAME,
        password = vim.env.YAARZ_READONLY_STG_DB_PASSWORD,
      },
      write = {
        username = vim.env.YAARZ_STG_DB_USERNAME,
        password = vim.env.YAARZ_STG_DB_PASSWORD,
      },
    }

    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1

    vim.g.dbs = {
      { name = "Yaarz - DEV", url = urlprefix .. "yaarz" },
      { name = "Yaarz - TEST", url = urlprefix .. "yaarz_test" },
      { name = "Yaarz - E2E TEST", url = urlprefix .. "yaarz_e2e_test" },
      {
        name = "Yaarz - STG readonly",
        url = "postgresql://"
          .. yaarzStg.readonly.username
          .. ":"
          .. yaarzStg.readonly.password
          .. "@b2jjkkefpdifbb1skobz-postgresql.services.clever-cloud.com:6769/b2jjkkefpdifbb1skobz",
      },
      {
        name = "Yaarz - STG",
        url = "postgresql://"
          .. yaarzStg.write.username
          .. ":"
          .. yaarzStg.write.password
          .. "@b2jjkkefpdifbb1skobz-postgresql.services.clever-cloud.com:6769/b2jjkkefpdifbb1skobz",
      },
      {
        name = "Yaarz - PROD readonly",
        url = "postgresql://"
          .. yaarzProd.readonly.username
          .. ":"
          .. yaarzProd.readonly.password
          .. "@b2jjkkefpdifbb1skobz-postgresql.services.clever-cloud.com:6769/b2jjkkefpdifbb1skobz",
      },
      {
        name = "Yaarz - PROD",
        url = "postgresql://"
          .. yaarzProd.write.username
          .. ":"
          .. yaarzProd.write.password
          .. "@b2jjkkefpdifbb1skobz-postgresql.services.clever-cloud.com:6769/b2jjkkefpdifbb1skobz",
      },
    }
  end,
  keys = {
    { "<leader>D", "<cmd>bd<cr><cmd>DBUIToggle<cr>" },
  },
}
