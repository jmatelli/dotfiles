return {
  "goolord/alpha-nvim",
  config = function()
    local alpha = require("alpha")

    local tmntWithTitle = {
      [[                                                         ]],
      [[                                                         ]],
      [[                                                         ]],
      [[                                                         ]],
      [[                                                         ]],
      [[              ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣤⣄⡀⠀⠀⠀⠀⢠⣤⣄⠀⣀⠀⠀              ]],
      [[              ⠀⠀⠀⠀⠀⠀⠀⣠⣴⠟⠛⠉⠁⠀⠀⠈⠉⠛⠻⣦⣄⠀⢸⡟⠙⣿⡟⣷⡀              ]],
      [[              ⠀⠀⠀⠀⠀⢠⣾⠏⠁⣀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡈⠻⣷⣼⣧⠀⢹⡇⣹⡇              ]],
      [[              ⠀⠀⠀⠀⣰⡿⠟⠛⢛⣛⣛⡿⢶⣶⣶⡶⢿⣛⣛⡛⠛⠿⢿⣿⣷⣿⣣⡿⠁              ]],
      [[              ⠀⠀⠀⠀⣿⠁⢀⣼⠟⣯⣝⣻⣦⣤⣤⣾⣟⣫⣭⠻⣷⡄⠈⣿⣨⣿⠋⠀⠀              ]],
      [[              ⠀⠀⣠⡾⠻⢷⣬⣛⣿⡿⠟⠋⠁⠀⠀⠈⠉⠛⢿⣿⣋⣵⡾⠛⢿⣅⠀⠀⠀              ]],
      [[              ⠀⣼⠟⠀⠀⠀⠉⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⠁⠀⠀⠀⠻⣧⠀⠀              ]],
      [[              ⠰⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠆⠀              ]],
      [[              ⠀⢻⣦⠀⠀⠀⠀⠀⢴⣤⣤⣀⣀⠀⠀⣀⣠⣤⡾⢿⡆⠀⠀⠀⠀⣴⡟⠀⠀              ]],
      [[              ⠀⠀⠙⢷⣤⣀⠀⠀⠀⠈⠉⠙⠛⠛⠛⠛⠉⠁⠀⠈⠁⠀⣀⣤⡾⠋⠀⠀⠀              ]],
      [[              ⠀⠀⠀⠀⠈⠛⠷⢶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⠟⠋⠁⠀⠀⠀⠀⠀              ]],
      [[              ⠀⠀⠀⠀⠀⠀⠀⠈⠛⢷⣤⣀⡀⠀⠀⢀⣠⣴⡾⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀              ]],
      [[              ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀              ]],
      [[                                                         ]],
      -- [[            ███╗   ██╗██╗   ██╗██╗███╗   ███╗            ]],
      -- [[            ████╗  ██║██║   ██║██║████╗ ████║            ]],
      -- [[            ██╔██╗ ██║██║   ██║██║██╔████╔██║            ]],
      -- [[            ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║            ]],
      -- [[            ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║            ]],
      -- [[            ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝            ]],
      [[         ████████╗███╗   ███╗███╗   ██╗████████╗         ]],
      [[         ╚══██╔══╝████╗ ████║████╗  ██║╚══██╔══╝         ]],
      [[            ██║   ██╔████╔██║██╔██╗ ██║   ██║            ]],
      [[            ██║   ██║╚██╔╝██║██║╚██╗██║   ██║            ]],
      [[            ██║   ██║ ╚═╝ ██║██║ ╚████║   ██║            ]],
      [[            ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═══╝   ╚═╝            ]],
      [[                                                         ]],
      [[                    (T. M. Neovim T.)                    ]],
      [[                                                         ]],
      [[                                                         ]],
    }

    local dashboard = require "alpha.themes.dashboard"
    local function header()
      return tmntWithTitle
    end

    dashboard.section.header.val = header()

    dashboard.section.buttons.val = {
      dashboard.button("SPC f f", "  Find File", ":Telescope find_files<CR>"),
      dashboard.button("SPC f o", "  Recent File", ":Telescope oldfiles<CR>"),
      dashboard.button("SPC f w", "ﳳ  Find word", ":Telescope live_grep<CR>"),
      dashboard.button("SPC e s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
    }

    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Function"
    dashboard.section.buttons.opts.hl_shortcut = "Type"
    dashboard.opts.opts.noautocmd = true

    alpha.setup(dashboard.opts)
  end,
}
