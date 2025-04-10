return {
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true, -- or `opts = {}`
  },

  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({
        transparent = true,
        on_highlights = function(hl, colors)
          hl.LspInlayHint = { fg = colors.polar_night.light }
        end,
      })
    end,
  },

  -- Configure LazyVim to load nord
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
