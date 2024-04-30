local M = {}
function M.setup()
  local harpoon = require("harpoon")
  harpoon.setup({})
end
function M.keymaps()
  local harpoon = require("harpoon")
  local conf = require("telescope.config").values
  local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
      table.insert(file_paths, item.value)
    end

    require("telescope.pickers")
      .new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
          results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
      })
      :find()
  end

  K.merge_wk({
    h = {
      name = "[H]arpoon",
      a = {
        function()
          require("harpoon"):list():add()
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
            require("harpoon"):list():remove_at(1)
          end,
          "Mark [1]",
        },
        ["2"] = {
          function()
            require("harpoon"):list():remove_at(2)
          end,
          "Mark [2]",
        },
        ["3"] = {
          function()
            require("harpoon"):list():remove_at(3)
          end,
          "Mark [3]",
        },
        ["4"] = {
          function()
            require("harpoon"):list():remove_at(4)
          end,
          "Mark [4]",
        },
        ["5"] = {
          function()
            require("harpoon"):list():remove_at(5)
          end,
          "Mark [5]",
        },
        ["6"] = {
          function()
            require("harpoon"):list():remove_at(6)
          end,
          "Mark [6]",
        },
      },
    },
    ["{"] = {
      function()
        require("harpoon"):list():prev()
      end,
      "Prev Harpoon",
    },
    ["}"] = {
      function()
        require("harpoon"):list():next()
      end,
      "Next Harpoon",
    },
  })
end
return M
