local M = {}

function M.setup()
  require("flash").setup({
    modes = {
      search = {
        enabled = false,
        mode = function(str)
          return "\\<" .. str
        end,
      },
      char = {
        enabled = true,
      },
    },
    jump = {
      autojump = false,
      search = {
        mode = function(str)
          return "\\<" .. str
        end,
      },
    },
    label = {
      after = false,
      before = true,
    },
    prompt = {
      enabled = true,
      prefix = { { "⚡", "FlashPromptIcon" } },
      win_config = {
        relative = "editor",
        width = 1, -- when <=1 it's a percentage of the editor width
        height = 1,
        row = -1, -- when negative it's an offset from the bottom
        col = 0, -- when negative it's an offset from the right
        zindex = 1000,
      },
    },
  })
end
    -- stylua: ignore
function M.keymaps()
  vim.keymap.set("n", "<leader>t", function()
require('flash').jump({
search = {
    mode = function(str)
      return "\\<" .. str
    end,
    },
  })
  end, {})
  K.map { "<leader>T", "Flash Treesitter",  "<cmd>lua require('flash').treesitter()<CR>",   mode = { "n", "x", "o" }}
  K.map { "r", "Flash Treesitter", "<cmd>lua require('flash').remote() <CR>",    mode = "o"}
  K.map { "R",  "Treesitter Search",  "<cmd>lua require('flash').treesitter_search()<CR>" , mode = {"o", "x"}}
  K.map { "<c-s>", "Toggle Flash Search", "<cmd>lua require('flash').toggle() <CR>", mode = { "c" }}
end
return M
