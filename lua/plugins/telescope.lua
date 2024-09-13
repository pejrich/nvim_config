local M = {}
local X = {}
local m = {}

function M.setup()
  local previewers = require("telescope.previewers")
  local Job = require("plenary.job")
  local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    -- if opts.use_ft_detect == nil then opts.use_ft_detect = true end
    -- opts.use_ft_detect = opts.use_ft_detect == false and false or
    --                          bad_files(filepath)
    filepath = vim.fn.expand(filepath)

    Job:new({
      command = "file",
      args = { "--mime-type", "-b", filepath },
      on_exit = function(j)
        local res = j:result()[1]
        local mime_type = vim.split(res, "/")[1]
        if mime_type == "text" or res == "application/json" then
          vim.loop.fs_stat(filepath, function(_, stat)
            if not stat then
              return
            end
            if stat.size > 100000 then
              vim.schedule(function()
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "FILE TOO LARGE" })
              end)
            else
              previewers.buffer_previewer_maker(filepath, bufnr, opts)
            end
          end)
        else
          -- maybe we want to write something to the buffer here
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
          end)
        end
      end,
    }):sync()
  end

  local plugin = require("telescope")
  local actions = require("telescope.actions")
  local editor = require("editor.searchreplace")
  local trouble = require("trouble.sources.telescope")

  local extensions = X.extensions()
  table.insert(extensions, {
    ["ui-select"] = {

      require("telescope.themes").get_dropdown(),
    },
  })
  table.insert(extensions, {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case",
    },
  })

  local grepargs = { editor.search.cmd }

  for _, arg in ipairs(editor.search.base_args) do
    table.insert(grepargs, arg)
  end

  table.insert(grepargs, editor.search.optional_args.with_hidden)
  table.insert(grepargs, editor.search.optional_args.smart_case)

  plugin.setup({
    defaults = {
      vimgrep_arguments = grepargs,
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          width = 0.8,
          preview_width = 0.5,
        },
        vertical = {
          width = 0.5,
          height = 0.7,
          preview_cutoff = 1,
          prompt_position = "top",
          preview_height = 0.4,
          mirror = true,
        },
      },
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_ignore_patterns = { "%.git/", "node_modules" },
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { "truncate" },
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = new_maker,
      mappings = {
        n = {
          ["<S-Down>"] = actions.file_split,
          ["<S-Right>"] = actions.file_vsplit,
          -- ["<C-t>"] = actions.preview_scrolling_up,
          -- ["<C-h>"] = actions.preview_scrolling_down,
          ["<D-w>"] = actions.close,
          ["<C-t>"] = trouble.open,
        },
        i = {
          ["<S-Down>"] = actions.file_split,
          ["<S-Right>"] = actions.file_vsplit,
          -- ["<C-t>"] = actions.preview_scrolling_up,
          -- ["<C-h>"] = actions.preview_scrolling_down,
          ["<D-w>"] = actions.close,
          ["<c-t>"] = trouble.open,
          ["<c-g>"] = X.toggle_hidden,
        },
      },
    },
    pickers = {
      buffers = {
        mappings = {
          n = { ["<D-BS>"] = actions.delete_buffer },
          i = { ["<D-BS>"] = actions.delete_buffer },
          -- ignore_current_buffer = true,
        },
        sort_mru = true,

        ignore_current_buffer = true,
      },
    },
    extensions = extensions,
  })

  pcall(function()
    for ext, _ in pairs(extensions) do
      plugin.load_extension(ext)
    end
  end)

  -- Enable telescope extensions, if they are installed
  pcall(require("telescope").load_extension, "fzf")
  pcall(require("telescope").load_extension, "ui-select")

  local find_frecancy = function()
    require("telescope").extensions.frecency.frecency({ workspace = "CWD", matcher = "fuzzy" })
  end

  -- See `:help telescope.builtin`
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>fa", function()
    builtin.find_files({
      find_command = {
        "fd",
        "--type",
        "f",
        "--no-ignore-vcs",
        "--color=never",
        "--hidden",
        "--follow",
      },
      hidden = true,
    })
  end, { desc = "[F]ind [A]ll" })
  vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
  vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
  -- vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
  vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind [S]elect Telescope" })
  vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
  vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
  vim.keymap.set("n", "<leader>fr", find_frecancy, { desc = "[F]ind f[R]ecency" })
  -- vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
  vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
  vim.keymap.set("n", "<leader><leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

  -- Slightly advanced example of overriding default behavior and theme
  vim.keymap.set("n", "<leader>/", function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end, { desc = "[/] Fuzzily search in current buffer" })

  -- Also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set("n", "<leader>f/", function()
    builtin.live_grep({
      grep_open_files = true,
      prompt_title = "Live Grep in Open Files",
    })
  end, { desc = "[F]ind [/] in Open Files" })

  -- Shortcut for searching your neovim configuration files
  vim.keymap.set("n", "<leader>fn", function()
    builtin.find_files({ cwd = vim.fn.stdpath("config") })
  end, { desc = "[F]ind [N]eovim files" })
end

function X.toggle_hidden(prompt_bufnr)
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local action_state = require("telescope.actions.state")

  local opts = {}
  opts.entry_maker = make_entry.gen_from_file(opts)

  local cmd = {
    "fd",
    "--type",
    "f",
    "--no-ignore-vcs",
    "--color=never",
    "--hidden",
    "--follow",
  }
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:refresh(finders.new_oneshot_job(cmd, opts), { no_ignore = true })
end

-- Extensions

function X.extensions()
  local fb = require("telescope._extensions.file_browser.actions")

  return {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    },
    frecency = {
      matcher = "fuzzy",
    },
    file_browser = {
      -- path
      -- cwd
      cwd_to_path = false,
      grouped = false,
      files = true,
      add_dirs = true,
      depth = 1,
      auto_depth = false,
      select_buffer = false,
      hidden = { file_browser = false, folder_browser = false },
      respect_gitignore = false,
      -- browse_files
      -- browse_folders
      hide_parent_dir = false,
      collapse_dirs = false,
      prompt_path = false,
      quiet = false,
      dir_icon = "",
      dir_icon_hl = "Default",
      display_stat = false,
      hijack_netrw = false,
      use_fd = true,
      git_status = false,
      mappings = {
        ["i"] = {
          ["<D-n>"] = fb.create,
          ["<S-CR>"] = fb.create_from_prompt,
          ["<D-r>"] = fb.rename,
          ["<D-m>"] = fb.move,
          ["<D-d>"] = fb.copy,
          ["<D-BS>"] = fb.remove,
          ["<D-o>"] = fb.open,
          ["<D-u>"] = fb.goto_parent_dir,
          ["<D-M-u>"] = fb.goto_cwd,
          ["<D-f>"] = fb.toggle_browser,
          ["<C-g>"] = fb.toggle_hidden,
          ["<D-a>"] = fb.toggle_all,
          ["<BS>"] = fb.backspace,
          ["<CR>"] = "select_default",
        },
        ["n"] = {
          ["<D-n>"] = fb.create,
          ["<S-CR>"] = fb.create_from_prompt,
          ["<D-r>"] = fb.rename,
          ["<D-m>"] = fb.move,
          ["<D-d>"] = fb.copy,
          ["<D-BS>"] = fb.remove,
          ["<D-o>"] = fb.open,
          ["<D-u>"] = fb.goto_parent_dir,
          ["<D-M-u>"] = fb.goto_cwd,
          ["<D-f>"] = fb.toggle_browser,
          ["<C-g>"] = fb.toggle_hidden,
          ["<D-a>"] = fb.toggle_all,
          ["ya"] = function(bufnr)
            m.copy_path(bufnr, "absolute")
          end,
          ["yr"] = function(bufnr)
            m.copy_path(bufnr, "relative")
          end,
          ["yn"] = function(bufnr)
            m.copy_path(bufnr, "filename")
          end,
          ["ys"] = function(bufnr)
            m.copy_path(bufnr, "filestem")
          end,
        },
      },
    },
  }
end

function M.keymaps()
  K.map({ "<D-e>", "Open file browser", m.open_file_browser, mode = { "n", "i", "v" } })

  K.map({ "<D-b>", "Open buffer selector", m.open_buffers, mode = { "n", "i", "v" } })
  K.map({ "<D-t>", "Open file finder", m.open_file_finder, mode = { "n", "i", "v" } })
  K.map({ "<D-f>", "Open project-wide text search", m.open_text_finder, mode = { "n", "i", "v" } })

  require("which-key").add({
    { "<leader>fc", m.open_command_finder, desc = "[C]ommand finder" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "[H]elp tags" },
    { "<leader>l", group = "[L]SP" },
    {
      "<leader>lf",
      function()
        vim.lsp.buf.format({ async = true })
      end,
      desc = "[F]ormat",
    },
    {
      "<leader>lx",
      function()
        m.open_diagnostics({ current_buffer = true })
      end,
      desc = "[D]iagnostics",
    },
    {
      "<leader>lp",
      function()
        m.open_diagnostics({ current_buffer = false })
      end,
      desc = "[P]roject Diagnostics",
    },
  })
end

-- Private

local wide_layout_config = {
  width = 0.8,
}

function m.open_file_browser()
  local extensions = require("telescope").extensions

  extensions.file_browser.file_browser({
    cwd = "%:p:h",
    hidden = true,
    git_status = false,
    respect_gitignore = false,
    grouped = true,
    select_buffer = true,
    initial_mode = "normal",
    file_ignore_patterns = { "%.git/" },
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.8,
      preview_width = 0.5,
    },
  })
end

function m.open_buffers()
  local telescope = require("telescope.builtin")
  local buffers = require("editor.buffers")

  local listed_buffers = buffers.get_listed_bufs()

  telescope.buffers({
    initial_mode = "insert",
    sort_mru = true,
    ignore_current_buffer = #listed_buffers > 1,
  })
end

function m.open_file_finder()
  local telescope = require("telescope.builtin")

  telescope.find_files({
    hidden = true,
    no_ignore = false,
    initial_mode = "insert",
    layout_strategy = "vertical",
  })
end

function m.open_text_finder()
  local telescope = require("telescope.builtin")

  telescope.live_grep({
    hidden = true,
    no_ignore = false,
    initial_mode = "insert",
    layout_strategy = "horizontal",
  })
end

function m.open_diagnostics(params)
  local telescope = require("telescope.builtin")

  local opts = {
    initial_mode = "normal",
    layout_strategy = "vertical",
    layout_config = wide_layout_config,
  }

  if params.current_buffer then
    opts.bufnr = 0
  end

  if params.min_severity then
    opts.severity_bound = "ERROR"
    opts.severity_limit = params.min_severity
  end

  telescope.diagnostics(opts)
end

function m.open_document_symbols()
  local telescope = require("telescope.builtin")

  telescope.lsp_document_symbols({
    initial_mode = "insert",
    layout_strategy = "vertical",
  })
end

function m.open_workspace_symbols()
  local telescope = require("telescope.builtin")

  telescope.lsp_workspace_symbols({
    initial_mode = "insert",
    layout_strategy = "vertical",
  })
end

function m.open_todos(params)
  if not params.todo and not params.fixme and not params.priority then
    vim.api.nvim_err_writeln("No keywords specified")
    return
  end

  local keywords = {}
  if params.priority then
    table.insert(keywords, "TODO!")
    table.insert(keywords, "FIXME!")
  else
    if params.todo then
      table.insert(keywords, "TODO")
      table.insert(keywords, "TODO!")
    end
    if params.fixme then
      table.insert(keywords, "FIXME")
      table.insert(keywords, "FIXME!")
    end
  end

  vim.cmd("TodoTelescope " .. "keywords=" .. table.concat(keywords, ",") .. " " .. "layout_strategy=vertical layout_config={width=0.7}")
end

function m.open_command_finder()
  local telescope = require("telescope.builtin")

  telescope.commands({
    initial_mode = "insert",
    layout_strategy = "vertical",
    layout_config = wide_layout_config,
  })
end

-- Utils

function m.copy_path(bufnr, fmt)
  local cb = require("editor.clipboard")
  local fs = require("editor.fs")
  local fb = require("telescope._extensions.file_browser.utils")

  local selections = fb.get_selected_files(bufnr, true)
  local entry = selections[1]

  if entry ~= nil then
    local result = fs.format(entry.filename, fmt)

    if result ~= nil then
      cb.yank(result)
      print("Copied to clipboard: " .. result)
      vim.defer_fn(function()
        vim.cmd.echo('""')
      end, 5000)
    end
  else
    vim.api.nvim_err_writeln("No file selected")
  end
end

return M
