local M = {}

function M.setup()
  local plugin = require("Comment")

  plugin.setup({
    -- Add a space b/w comment and the line
    padding = true,
    -- Whether the cursor should stay at its position
    sticky = true,
    -- LHS of toggle mappings in NORMAL mode
    toggler = {
      -- Line-comment toggle keymap
      line = "gc",
      -- Block-comment toggle keymap
      block = "gb",
    },
    -- LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
      -- Line-comment keymap
      line = "gc",
      -- Block-comment keymap
      block = "gb",
    },
    -- LHS of extra mappings
    extra = {},
    -- Enable keybindings
    mappings = {
      basic = true,
      extra = false,
    },
    ---Function to call before (un)comment
    pre_hook = nil,
    ---Function to call after (un)comment
    post_hook = nil,
  })
end

function M.keymaps()
  K.map({ "<D-/>", "Toggle comments", "<Plug>(comment_toggle_linewise_current)", mode = "n" })
  K.map({ "<D-/>", "Toggle comments", "<Plug>(comment_toggle_linewise_visual)", mode = "v" })
  K.map({ "<D-/>", "Toggle comments", "<Esc><Plug>(comment_toggle_linewise_current)A", mode = "i" })
end

return M
