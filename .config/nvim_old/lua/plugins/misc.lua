return {
    {
        "echasnovski/mini.diff",
        version = false,
        config = function()
            require("mini.diff").setup()
        end,
    },
    { "echasnovski/mini.notify", version = false, config = true },
    {
        "echasnovski/mini.move",
        version = false,
        config = function()
            require("mini.move").setup()
        end,
    },
    "RRethy/vim-illuminate",
    {
        "stevearc/dressing.nvim",
        opts = {},
    },
    "cohama/lexima.vim", -- autopairs
    "tpope/vim-fugitive",

    -- aesthetics
    {
        "brenoprata10/nvim-highlight-colors",
        event = "VeryLazy",
        opts = {
            enable_tailwind = true,
        },
        enable = false,
    },
    {
        "norcalli/nvim-colorizer.lua",
        event = "BufEnter",
        opts = { "*" },
    },
    {
        "luckasRanarison/tailwind-tools.nvim",
        name = "tailwind-tools",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim", -- optional
            "neovim/nvim-lspconfig",         -- optional
        },
        opts = {},
    },
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },
    {
        "m4xshen/hardtime.nvim",
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            disabled_filetypes = { "dbui", "dbout", "oil" }
        }
    },
    {
        "lukas-reineke/headlines.nvim",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = true, -- or `opts = {}`
    },
    {
        "mistweaverco/kulala.nvim",
        config = function()
            -- Setup is required, even if you don't pass any options
            require('kulala').setup()
        end
    },
    {
        "nvzone/typr",
        dependencies = "nvzone/volt",
        opts = {},
        cmd = { "Typr", "TyprStats" },
    }
}
