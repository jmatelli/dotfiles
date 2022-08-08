local M = {}

local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local Job = require("plenary.job")

local new_maker = function(filepath, bufnr, opts)
  filepath = vim.fn.expand(filepath)
  Job:new({
    command = "file",
    args = { "--mime-type", "-b", filepath },
    on_exit = function(j)
      local mime_type = vim.split(j:result()[1], "/")[1]
      if mime_type == "text" then
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      else
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
        end)
      end
    end
  }):sync()
end

M.project_files = function()
  local opts = {
    show_untracked = true,
  }
  local ok = pcall(require"telescope.builtin".git_files, opts)
  if not ok then
    require"telescope.builtin".find_files(opts)
  end
end

M.setup = function()
  local tree_exists, tree = pcall(require, "nvim-tree.api")

  if not tree_exists then
    return
  end

  require("core.utils").load_highlights "telescope"
  require("telescope").setup {
    defaults = {
      buffer_previewer_maker = new_maker,
      mappings = {
        i = {
          ["<esc>"] = actions.close,
          ["<F2>"] = function(prompt_bufnr)
            actions.close(prompt_bufnr)
            tree.tree.toggle()
          end,
          ["<F3>"] = function(prompt_bufnr)
            actions.close(prompt_bufnr)
            tree.tree.focus()
          end,
        },
      },
      prompt_prefix = "  ",
      selection_caret = " ",
      entry_prefix = "  ",
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.5,
          results_width = 0.5,
        },
        vertical = {
          mirror = false,
        },
        width = 0.7,
        height = 0.8,
        preview_cutoff = 120,
      },
      file_ignore_patterns = { "node_modules" },
      path_display = { "truncate" },
      winblend = 1,
      border = {},
      borderchars = { " ", "", "", "", "", "", "", "" },
      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    },
    pickers = {
      buffers = {
        sort_lastused = true,
      },
      find_files = {
        find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
      },
    },
  }
end

return M
