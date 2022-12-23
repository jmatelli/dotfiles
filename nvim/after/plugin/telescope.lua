local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local Job = require("plenary.job")
local utils = require("core.utils")
local default_opts = { noremap = true, silent = true }

utils.nleader("<leader>", ":Telescope buffers<CR>", default_opts)
utils.nnoremap("<C-p>", ":Telescope find_files<CR>", default_opts)

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

local telescope = require("telescope")
local tree = require("nvim-tree.api")

telescope.load_extension("fzf")
telescope.load_extension("emoji")
telescope.load_extension("glyph")
telescope.load_extension("ui-select")

telescope.setup {
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
