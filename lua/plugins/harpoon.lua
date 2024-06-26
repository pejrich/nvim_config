local M = {}
function M.setup()
  local harpoon = require("harpoon")
  harpoon.setup({})
end
function M.keymaps()
  local harpoon = require("harpoon")
  local conf = require("telescope.config").values
  local function toggle_telescope(harpoon_files)
    local make_finder = function()
      local paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(paths, item.value)
      end

      return require("telescope.finders").new_table({
        results = paths,
      })
    end

    require("telescope.pickers")
      .new({}, {
        prompt_title = "Harpoon",
        finder = make_finder(),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_buffer_number, map)
          local delete = function()
            local state = require("telescope.actions.state")
            local selected_entry = state.get_selected_entry()
            local current_picker = state.get_current_picker(prompt_buffer_number)

            harpoon:list():remove_at(selected_entry.index)
            current_picker:refresh(make_finder())
            -- current_picker:set_selection(selected_entry.index)
          end
          map("i", "<M-d>", delete)
          map("n", "dd", delete)

          return true
        end,
      })
      :find()
  end
  vim.keymap.set("n", "<M-1>", function()
    require("harpoon"):list():select(1)
  end, { desc = "Harpoon 1" })
  vim.keymap.set("n", "<M-2>", function()
    require("harpoon"):list():select(2)
  end, { desc = "Harpoon 2" })
  vim.keymap.set("n", "<M-3>", function()
    require("harpoon"):list():select(3)
  end, { desc = "Harpoon 3" })
  vim.keymap.set("n", "<M-4>", function()
    require("harpoon"):list():select(4)
  end, { desc = "Harpoon 4" })

  K.merge_wk({
    h = {
      name = "[H]arpoon",
      a = {
        function()
          harpoon:list():add()
        end,
        "[A]dd",
      },
      l = {
        function()
          toggle_telescope(require("harpoon"):list())
        end,
        "[L]ist",
      },
      d = {
        name = "[D]elete",
        ["1"] = {
          function()
            harpoon:list():remove_at(1)
          end,
          "Mark [1]",
        },
        ["2"] = {
          function()
            harpoon:list():remove_at(2)
          end,
          "Mark [2]",
        },
        ["3"] = {
          function()
            harpoon:list():remove_at(3)
          end,
          "Mark [3]",
        },
        ["4"] = {
          function()
            harpoon:list():remove_at(4)
          end,
          "Mark [4]",
        },
        ["5"] = {
          function()
            harpoon:list():remove_at(5)
          end,
          "Mark [5]",
        },
        ["6"] = {
          function()
            harpoon:list():remove_at(6)
          end,
          "Mark [6]",
        },
      },
    },

    ["{"] = {
      function()
        harpoon:list():prev()
      end,
      "Prev Harpoon",
    },
    ["}"] = {
      function()
        harpoon:list():next()
      end,
      "Next Harpoon",
    },
  })
end
return M
