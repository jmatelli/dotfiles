return {
  "norcalli/nvim-colorizer.lua",
  config = function()
    local colorizer = require("colorizer")

    colorizer.setup({
      "*",
      css = { css_fn = true, RRGGBBAA = true },
    }, {
      names = false,
    })

    vim.cmd "ColorizerAttachToBuffer"
  end,
}
