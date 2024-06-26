local M = {}

function M.setup()
  require("flash").setup({
    modes = {
      search = {
        enabled = false,
      },
      char = {
        enabled = false,
      },
    },
    jump = {
      autojump = false,
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
      K.map { "<leader>t",  "Flash", "<cmd>lua require('flash').jump()<CR>",  mode = { "n", "x", "o" }}
    K.map { "<leader>T", "Flash Treesitter",  "<cmd>lua require('flash').treesitter()<CR>",   mode = { "n", "x", "o" }}
     K.map { "r", "Flash Treesitter", "<cmd>lua require('flash').remote() <CR>",    mode = "o"}
     K.map { "R",  "Treesitter Search",  "<cmd>lua require('flash').treesitter_search()<CR>" , mode = {"o", "x"}}
     K.map { "<c-s>", "Toggle Flash Search", "<cmd>lua require('flash').toggle() <CR>", mode = { "c" }}
end
return M
