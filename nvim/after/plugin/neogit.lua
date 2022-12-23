local git = require("neogit")

git.setup({
  kind = "floating",
  popup = {
    kind = "floating",
  },
  signs = {
    -- { CLOSED, OPENED }
    section = { "", "" },
    item = { "", "" },
    hunk = { "", "" },
  },
})
