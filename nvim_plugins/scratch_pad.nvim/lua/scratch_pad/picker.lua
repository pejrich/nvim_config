local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local putils = require("telescope.previewers.utils")
local previewers = require("telescope.previewers")
local from_entry = require("telescope.from_entry")
local scratch = require("scratch_pad")
local timeago = require("scratch_pad.timeago")
-- our picker function: colors
function M.open_picker(opts)
  opts = opts or {}

  local make_finder = function()
    local vals = {}
    for k, v in pairs(scratch.state.bufs) do
      table.insert(vals, v)
    end
    table.sort(vals, function(a, b)
      return a.created_at > b.created_at
    end)
    return finders.new_table({
      results = vals,
      entry_maker = function(entry)
        local display = "# "
          .. tostring(entry.id)
          .. string.rep(" ", 10 - #tostring(entry.id))
          .. timeago.format(entry.created_at)
        display = display .. string.rep(" ", 45 - #display) .. (entry.filetype or "-")
        return {
          value = entry,
          display = display,
          ordinal = tostring(entry.id),
        }
      end,
    })
  end
  pickers
    .new(opts, {
      prompt_title = "Scratch Pads",
      finder = make_finder(),
      previewer = previewers.new_buffer_previewer({
        define_preview = function(self, entry, status)
          vim.api.nvim_set_option_value("filetype", entry.value.filetype, { buf = self.state.bufnr })
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.value.lines)
        end,
      }),
      -- previewer = previewers.vim_buffer_cat.new(opts),
      -- previewer = require("telescope.previewers").new_buffer_previewer({
      --   title = "Git Branch Diff Preview",
      --   get_buffer_by_name = function(_, entry)
      --     print(entry.value)
      --     return entry.value
      --   end,
      --
      --   define_preview = function(self, entry, _)
      --     local file_name = entry.value
      --     local get_git_status_command = "git status -s -- " .. file_name
      --     local git_status = io.popen(get_git_status_command):read("*a")
      --     local git_status_short = string.sub(git_status, 1, 1)
      --     if git_status_short ~= "" then
      --       local p = from_entry.path(entry, true)
      --       if p == nil or p == "" then
      --         return
      --       end
      --       conf.buffer_previewer_maker(p, self.state.bufnr, {
      --         bufname = self.state.bufname,
      --         winid = self.state.winid,
      --       })
      --     else
      --       putils.job_maker({ "git", "--no-pager", "diff", "master" .. "..HEAD", "--", file_name }, self.state.bufnr, {
      --         value = file_name,
      --         bufname = self.state.bufname,
      --       })
      --       putils.regex_highlighter(self.state.bufnr, "diff")
      --     end
      --   end,
      -- }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.delete_buffer:replace(function()
          local current_picker = action_state.get_current_picker(prompt_bufnr)
          current_picker:delete_selection(function(selection)
            -- delete the selection outside of telescope
          end)
        end)

        local delete = function()
          local state = require("telescope.actions.state")
          local selected_entry = state.get_selected_entry()
          scratch.state:delete_buffer(selected_entry.value.id)
          local current_picker = state.get_current_picker(prompt_bufnr)
          current_picker:refresh(make_finder())

          -- current_picker:set_selection(selected_entry.index)
        end
        map("i", "<M-d>", delete)
        map("n", "dd", delete)

        local edit_ft = function()
          local state = require("telescope.actions.state")
          local selected_entry = state.get_selected_entry()
          local current_picker = state.get_current_picker(prompt_bufnr)
          vim.ui.select({ "elixir", "python", "rust", "lua", "javascript", "typescript", "json" }, {}, function(choice)
            local buf = scratch.state:get_buffer(selected_entry.value.id)
            if buf then
              buf.filetype = choice
              buf.scores = "done"
            end
            scratch.state:save_state()
            current_picker:refresh(make_finder())
          end)
        end
        map("i", "<tab>", edit_ft)
        map("n", "<tab>", edit_ft)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          scratch.open_buffer(selection.value.id)
          -- print(vim.inspect(selection))
          -- vim.api.nvim_put({ selection[1] }, "", false, true)
        end)
        return true
      end,
    })
    :find()
end

return M
