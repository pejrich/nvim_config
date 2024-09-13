local M = {}

function M.setup()
  local neoscroll = require("neoscroll")
  neoscroll.setup({
    easing_function = "cubic",
  })

  local keymap = {
    ["<C-u>"] = function()
      neoscroll.ctrl_u({ duration = 150 })
    end,
    ["<C-d>"] = function()
      neoscroll.ctrl_d({ duration = 150 })
    end,
    ["zz"] = function()
      neoscroll.zz({ half_win_duration = 150 })
    end,
    ["zt"] = function()
      neoscroll.zt({ half_win_duration = 150 })
    end,
    ["zb"] = function()
      neoscroll.zb({ half_win_duration = 150 })
    end,
  }
  local modes = { "n", "v", "x" }
  for key, func in pairs(keymap) do
    vim.keymap.set(modes, key, func)
  end
end

return M
