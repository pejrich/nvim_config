local M = {}

function M.setup()
  vim.o.timeout = true
  vim.o.timeoutlen = 500
  -- local presets = require("which-key.plugins.registers")
  -- presets.actions = {}

  require("which-key").setup({
    preset = "classic",
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },

    -- disable = {
    --   trigger = function(ctx)
    --     return true
    --   end,
    -- },
    -- triggers_nowait = {
    --   -- marks
    --   "`",
    --   "'",
    --   "g`",
    --   "g'",
    --   -- registers
    --   '"',
    --   "<c-r>",
    --   -- spelling
    --   "z=",
    -- },
  })
  -- -- Document existing key chains
  -- require("which-key").add({
  --   { "<leader>c", group = "[C]ode" },
  --   { "<leader>c_", hidden = true },
  --   { "<leader>d", group = "[D]ocument" },
  --   { "<leader>d_", hidden = true },
  --   { "<leader>r", group = "[R]ename" },
  --   { "<leader>r_", hidden = true },
  --   { "<leader>w", group = "[W]orkspace" },
  --   { "<leader>w_", hidden = true },
  --   -- ['<leader>q'] = { name = '[Q]uit/close buffer', _ = 'which_key_ignore' },
  -- })
end

return M
