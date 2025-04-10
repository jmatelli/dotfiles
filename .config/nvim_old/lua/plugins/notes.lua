return {
    "nvim-neorg/neorg",
    lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-neorg/neorg-telescope" } },
    config = function()
        require("neorg").setup {
            load = {
                ["core.autocommands"] = {},
                ["core.defaults"] = {},
                ["core.concealer"] = {
                    config = {
                        icons = {
                            todo = {
                                pending = { icon = ">" },
                                undone = { icon = " " },
                                done = { icon = "✓" },
                                cancelled = { icon = "" },
                                urgent = { icon = "!" },
                                on_hold = { icon = "?" },
                                recurring = { icon = "" },
                            },
                        }
                    }
                },
                ["core.completion"] = {
                    config = {
                        engine = "nvim-cmp",
                    }
                },
                ["core.dirman.utils"] = {},
                ["core.dirman"] = {
                    config = {
                        workspaces = {
                            notes = "~/notes",
                        },
                        default_workspace = "notes",
                    },
                },
                ["core.export"] = {
                    -- :Neorg export file.md
                    config = {
                        export_dir = "~/markdown"
                    }
                },
                ["core.itero"] = {},
                ["core.pivot"] = {},
                -- <LocalLeader>lt => list toggle
                -- <LocalLeader>li => list invert
                ["core.promo"] = {},
                ["core.summary"] = {}, -- :Neorg generate-workspace-summary
                ["core.ui"] = {},

                ["core.qol.toc"] = {},
                ["core.qol.todo_items"] = {},
                -- <Plug>(neorg.qol.todo_items.todo.task-done) (<LocalLeader>td)
                -- <Plug>(neorg.qol.todo_items.todo.task-undone) (<LocalLeader>tu)
                -- <Plug>(neorg.qol.todo_items.todo.task-pending) (<LocalLeader>tp)
                -- <Plug>(neorg.qol.todo_items.todo.task-on_hold) (<LocalLeader>th)
                -- <Plug>(neorg.qol.todo_items.todo.task-cancelled) (<LocalLeader>tc)
                -- <Plug>(neorg.qol.todo_items.todo.task-recurring) (<LocalLeader>tr)
                -- <Plug>(neorg.qol.todo_items.todo.task-important) (<LocalLeader>ti)
                -- <Plug>(neorg.qol.todo_items.todo.task-cycle) (<C-Space>)

                ["core.integrations.telescope"] = {},
                ["core.integrations.treesitter"] = {},

                ["core.esupports.indent"] = {},
                ["core.esupports.hop"] = {},
                ["core.esupports.metagen"] = {},
            },
        }

        vim.wo.conceallevel = 2
    end,
    keys = {
        { "<leader>nh", "<CMD>Telescope neorg search_headings<CR>",  "[N]org [H]eadings" },
        { "<leader>nw", "<CMD>Telescope neorg switch_workspace<CR>", "[N]org [W]orkspace" },
        { "<leader>nf", "<CMD>Telescope neorg find_norg_files<CR>",  "[N]org [F]iles" },
    },
}
