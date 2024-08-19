local M = {}
local m = {}

function M.setup()
  local plugin = require("persistence")

  plugin.setup({
    options = { "globals" },
    pre_save = function()
      local lazy = require("plugins.lazy")
      local noice = require("plugins.noice")
      local spectre = require("plugins.spectre")
      local filetree = require("plugins.neo-tree")
      local toggleterm = require("plugins.toggleterm")
      local mason = require("plugins.lsp.mason")
      local lazygit = require("plugins.git.lazygit")
      local diffview = require("plugins.git.diffview")

      local mode = vim.fn.mode()

      if mode == "i" or mode == "v" then
        local keys = require("editor.keys")
        keys.send("<Esc>", { mode = "x" })
      end

      lazy.ensure_hidden()
      noice.ensure_hidden()
      spectre.ensure_any_closed()
      filetree.ensure_any_hidden()
      toggleterm.ensure_any_hidden()
      mason.ensure_hidden()
      lazygit.ensure_hidden()
      diffview.ensure_all_hidden()
      vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })

      -- For some reason, it breaks persistence so that the session is not saved
      -- vim.cmd "wa"
    end,
    save_empty = true,
  })
end

function M.keymaps()
  require("which-key").add({
    { "<leader><leader>r", m.restore_session, desc = "[R]estore Prev Session" },
  })
end

-- Private

function m.restore_session()
  local persistence = require("persistence")

  persistence.load({ last = true })
end

return M
