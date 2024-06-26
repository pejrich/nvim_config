local M = {}

function M.setup()
  vim.o.timeout = true
  vim.o.timeoutlen = 500
  local presets = require("which-key.plugins.registers")
  presets.actions = {}

  require("which-key").setup({
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },

    triggers_nowait = {
      -- marks
      "`",
      "'",
      "g`",
      "g'",
      -- registers
      '"',
      "<c-r>",
      -- spelling
      "z=",
    },
  })
  -- Document existing key chains
  require("which-key").register({
    ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
    ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
    ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
    ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
    ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
    -- ['<leader>q'] = { name = '[Q]uit/close buffer', _ = 'which_key_ignore' },
  })
end

return M
