return {
    {
        "nvim-telescope/telescope-ui-select.nvim",
    },
    {
        "LukasPietzschmann/telescope-tabs",
        keys = {
            {
                "<leader>aa",
                "<CMD>tabnew<CR>",
                desc = "Open a new tab",
            },
            {
                "<leader>tp",
                "<CMD>tabprev<CR>",
                desc = "Go to previous tab",
            },
            {
                "<leader>tn",
                "<CMD>tabnext<CR>",
                desc = "Go to next tab",
            },
            {
                "<leader>qq",
                "<CMD>tabclose<CR>",
                desc = "Close current tab",
            },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.7",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            local themes = require("telescope.themes")

            telescope.setup({
                pickers = {
                    buffers = {
                        sort_lastused = true,
                    },
                    find_files = {
                        find_command = { "rg", "--files", "--hidden" },
                        hidden = true,
                    },
                },
                defaults = {
                    file_ignore_patterns = { "node_modules", "mocks" },
                    path_display = { "smart" }
                },
                extensions = {
                    ["ui-select"] = {
                        themes.get_dropdown({}),
                    },
                },
            })

            telescope.load_extension("ui-select")
            telescope.load_extension("telescope-tabs")
            require("telescope-tabs").setup({})
        end,
        keys = {
            {
                "<C-p>",
                "<CMD>Telescope find_files<CR>",
                desc = "Find files",
            },
            {
                "<leader>fw",
                "<CMD>Telescope live_grep<CR>",
                desc = "Live grep",
            },
            {
                "<leader>fk",
                "<CMD>Telescope grep_string<CR>",
                desc = "Grep string",
            },
            {
                "<leader><leader>",
                "<CMD>Telescope buffers<CR>",
                desc = "Grep string",
            },
            {
                "<leader>ts",
                "<CMD>Telescope colorscheme<CR>",
                desc = "Colorscheme",
            },
            {
                "<leader>tt",
                "<CMD>Telescope telescope-tabs list_tabs<CR>",
                desc = "Tabs",
            },
        },
    },
}
