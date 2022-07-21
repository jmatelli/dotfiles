local M = {}

function M.setup()
  local status_ok, alpha = pcall(require, "alpha")
  if not status_ok then
    return
  end

  local dashboard = require "alpha.themes.dashboard"
  local function header()
    return {
      [[                                              iiiiiiii                               ]],
      [[                                              i::::::i                               ]],
      [[                                              i::::::i                               ]],
      [[                                              iiiiiiii                               ]],
      [[                                                                                     ]],
      [[   nnnn  nnnnnnnn    vvvvvvv           vvvvvvv iiiiii mmmm  mmmmmmmm  mmmmmmmm       ]],
      [[   n:::nn::::::::nn   v:::::v         v:::::v  i::::i m:::mm::::::::mm::::::::mm     ]],
      [[   n::::::::::::::nn   v:::::v       v:::::v   i::::i m::::::::::::::m:::::::::mm    ]],
      [[   nn:::::::::::::::n   v:::::v     v:::::v    i::::i mm:::::::::::::::::::::::::m   ]],
      [[     n:::::nnnn:::::n    v:::::v   v:::::v     i::::i   m:::::mmmm::::::mmmm:::::m   ]],
      [[     n::::n    n::::n     v:::::v v:::::v      i::::i   m::::m    m::::m    m::::m   ]],
      [[     n::::n    n::::n      v:::::v:::::v       i::::i   m::::m    m::::m    m::::m   ]],
      [[     n::::n    n::::n       v:::::::::v        i::::i   m::::m    m::::m    m::::m   ]],
      [[     n::::n    n::::n        v:::::::v         i::::i   m::::m    m::::m    m::::m   ]],
      [[     n::::n    n::::n         v:::::v          i::::i   m::::m    m::::m    m::::m   ]],
      [[     n::::n    n::::n          v:::v           i::::i   m::::m    m::::m    m::::m   ]],
      [[     nnnnnn    nnnnnn           vvv            iiiiii   mmmmmm    mmmmmm    mmmmmm   ]],
    }
  end

  dashboard.section.header.val = header()
  
  dashboard.section.buttons.val = {
    dashboard.button("e", "📁 New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("c", "⚙ Configuration", ":e $MYVIMRC <CR>"),
    dashboard.button("q", "⊗ Quit Neovim", ":qa<CR>"),
  }

  local function footer()
    -- Number of plugins
    local total_plugins = #vim.tbl_keys(packer_plugins)
    local datetime = os.date "%d-%m-%Y · %H:%M:%S"
    local plugins_text = "\t" .. total_plugins .. " plugins · " .. datetime

    -- Quote
    local fortune = require "alpha.fortune"
    local quote = table.concat(fortune(), "\n")

    return plugins_text .. "\n" .. quote
  end

  dashboard.section.footer.val = footer()
  
  dashboard.section.footer.opts.hl = "Constant"
  dashboard.section.header.opts.hl = "Include"
  dashboard.section.buttons.opts.hl = "Function"
  dashboard.section.buttons.opts.hl_shortcut = "Type"
  dashboard.opts.opts.noautocmd = true

  alpha.setup(dashboard.opts)
end

return M
