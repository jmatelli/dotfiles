local M = {}

local file = "config/tokyonight.lua"

M.setup = function()
  local status_ok, tokyonight = pcall(require, "tokyonight")

  if not status_ok then
    return vim.notify("Could not load tokyonight in " .. file)
  end

  tokyonight.setup({
    on_highlights = function(hl, c)
      local prompt = "#2d3149"
      hl.TelescopeBorder = {
        bg = c.bg_highlight,
        fg = c.bg_highlight,
      }
      hl.TelescopeNormal = {
        bg = c.bg_highlight,
        fg = c.fg_dark,
      }
      hl.TelescopePromptBorder = {
        bg = prompt,
        fg = prompt,
      }
      hl.TelescopePromptNormal = {
        bg = prompt,
      }
      hl.TelescopePromptPrefix = {
        bg = prompt,
        fg = c.purple,
      }
      hl.TelescopePromptTitle = {
        bg = c.purple,
        fg = c.bg_dark,
      }
      hl.TelescopePreviewTitle = {
        bg = c.cyan,
        fg = c.bg_dark,
      }
      hl.TelescopePreviewNormal = {
        bg = c.bg_dark,
      }
      hl.TelescopePreviewBorder = {
        bg = c.bg_dark,
      }
      hl.TelescopeResultsTitle = {
        bg = c.red,
        fg = c.bg_dark,
      }
      hl.TelescopeMatching = {
        fg = c.red,
      }
    end,
  })

  vim.cmd[[colorscheme tokyonight-storm]]
end

return M
