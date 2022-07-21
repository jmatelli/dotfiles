local M = {}

function M.setup()
    require("nvim-treesitter.configs").setup {
        -- One of "all", "maintained" (parsers with maintainers), or a list of languages
        ensure_installed = { "bash", "css", "dockerfile", "go", "gomod", "gowork", "html", "javascript", "json", "lua", "make", "markdown", "markdown_inline", "scss", "sql", "tsx", "typescript", "vim" },

        -- Install languages synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        highlight = {
            -- `false` will disable the whole extension
            enable = true,
        },
    }
end

return M
