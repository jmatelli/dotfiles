local M = {}

local keymap = vim.keymap.set

local function nnoremap(lhs, rhs, options)
    keymap('n', lhs, rhs, options or { silent = true })
end
local function nleader(lhs, rhs, options)
    keymap('n', '<leader>'..lhs, rhs, options or { silent = true })
end

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings
    -- See `:h vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    nnoremap("gD", vim.lsp.buf.declaration, bufopts)
    nnoremap("gd", vim.lsp.buf.definition, bufopts)
    nnoremap("K", vim.lsp.buf.hover, bufopts)
    nnoremap("gi", vim.lsp.buf.implementation, bufopts)
    nnoremap("<C-k>", vim.lsp.buf.signature_help, bufopts)
    nleader("wa", vim.lsp.buf.add_workspace_folder, bufopts)
    nleader("wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    nleader("wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    nleader("D", vim.lsp.buf.type_definition, bufopts)
    nleader("rn", vim.lsp.buf.rename, bufopts)
    nleader("ca", vim.lsp.buf.code_action, bufopts)
    nnoremap("gr", vim.lsp.buf.references, bufopts)
    nleader("f", vim.lsp.buf.formatting, bufopts)
end

function M.setup()
    local util = require "lspconfig/util"

    local opts = { noremap = true, silent = true }
    nleader("e", vim.diagnostic.open_float, opts)
    nnoremap("[d", vim.diagnostic.goto_prev, opts)
    nnoremap("]d", vim.diagnostic.goto_next, opts)
    nleader("q", vim.diagnostic.setloclist, opts)

    local lsp_flags = {
        -- This is the default in Nvim 0.7+
        debounce_text_changes = 150,
    }

    require("lspconfig")["tsserver"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
    }

    require("lspconfig")["tailwindcss"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "html", "markdown", "mdx", "css", "less", "postcss", "sass", "scss", "stylus", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    }

    require("lspconfig")["gopls"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        cmd = { "gopls", "serve" },
        root_dir = util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
            },
        },
    }

    require("lspconfig")["dockerls"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }

    require("lspconfig")["bashls"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }

    require("lspconfig")["emmet_ls"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
    }

    require("lspconfig")["sqlls"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }

    require("lspconfig")["stylelint_lsp"].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            stylelintplus = {
                autoFixOnSave = true,
            }
        },
    }

    require("lspconfig")["diagnosticls"].setup {
        on_attach = on_attach,
        filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "css", "less", "scss", "markdown" },
        init_options = {
            linters = {
                eslint = {
                    command = "eslint_d",
                    rootPatterns = { ".git" },
                    debounce = 100,
                    args = { "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
                    sourceName = "esling_d",
                    parseJson = {
                        errorsRoot = "[0].messages",
                        line = "line",
                        column = "column",
                        endLine = "endLine",
                        endColumn = "endColumn",
                        message = "[esling] ${message} [${ruleId}]",
                        security = "severity",
                    },
                    securities = {
                        [2] = "error",
                        [1] = "warning",
                    }
                },
            },
            filetypes = {
                javascript = "eslint",
                javascriptreact = "eslint",
                typescript = "eslint",
                typescriptreact = "eslint",
            },
            formatters = {
                eslint_d = {
                    command = "eslint_d",
                    args = { "--stdin", "--stdin-filename", "%filename", "--fix-to-stdout" },
                    rootPatterns = { ".git" },
                },
                prettier = {
                    command = "prettier",
                    args = { "--stdin-filepath", "%filename" },
                },
            },
            formatFiletypes = {
                javascript = "eslint_d",
                javascriptreact = "eslint_d",
                typescript = "eslint_d",
                typescriptreact = "eslint_d",
                css = "prettier",
                json = "prettier",
                scss = "prettier",
                less = "prettier",
                markdown = "prettier",
            },
        },
    }
end

return M
