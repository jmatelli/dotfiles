local android_sdk = vim.env.ANDROID_HOME or (vim.env.HOME .. "/Library/Android/sdk")
local android_jar = android_sdk .. "/platforms/android-35/android.jar"

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = true,
        exclude = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
      },
      servers = {
        sourcekit = {
          cmd = { "xcrun", "sourcekit-lsp" },
          filetypes = { "swift", "objc", "objcpp" },
        },
        kotlin_language_server = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
          settings = {
            kotlin = {
              compiler = {
                jvm = { target = "17" },
              },
              completion = {
                snippets = { enabled = true },
              },
              externalSources = {
                autoConvertToKotlin = true,
              },
              -- passes android.jar on the compiler classpath for non-Gradle contexts
              -- (Gradle projects resolve this automatically via project sync)
              java = {
                opts = vim.fn.filereadable(android_jar) == 1 and { "-cp", android_jar } or {},
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
            format = true,
          },
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                client:request_sync("workspace/executeCommand", {
                  command = "eslint.applyAllFixes",
                  arguments = {
                    {
                      uri = vim.uri_from_bufnr(bufnr),
                      version = vim.lsp.util.buf_versions[bufnr],
                    },
                  },
                }, nil, bufnr)
              end,
            })
          end,
        },
      },
    },
    keys = {
      {
        "<S-d>",
        function()
          vim.diagnostic.jump({ count = 1, float = true })
        end,
        desc = "Next diagnostic",
      },
      {
        "<S-u>",
        function()
          vim.diagnostic.jump({ count = -1, float = true })
        end,
        desc = "Previous diagnostic",
      },
    },
  },
}
