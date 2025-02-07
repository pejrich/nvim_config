local M = {}
local L = {}
local utils = require("chuck_and_grab.utils")
local section = require("chuck_and_grab.section")
local single = require("chuck_and_grab.single")
local move_after = require("chuck_and_grab.move_after")

local pairs = require("chuck_and_grab.pairs")
function M.chuck_fwd(count)
  local pos = utils.curpos()
  local text = utils.get_text(pos, { pos[1], pos[2] + 3 })
  pairs.is_pair(text:sub(1, 1), text:sub(2, 2))
end

M.called_func = nil
M.called_count = nil
M.chuck_or_grab = "c"
M.finished = function() end

function M.callback()
  if M.called_func then
    if M.chuck_or_grab == "chuck" then
      local deactivate_move_after = move_after.init()
      M.finished = function(final)
        deactivate_move_after(M.called_count or 0, final)
      end
    else
      M.finished = function() end
    end
    M.called_func(M.called_count or 0)
  end
end
function M.setup()
  local f = function(fun, cg)
    return function()
      M.called_func = fun
      M.chuck_or_grab = cg
      M.called_count = vim.v.count
      vim.go.operatorfunc = "v:lua.require'chuck_and_grab'.callback"
      return "g@l"
    end
  end

  local km = vim.keymap.set
  local opts = { noremap = true, silent = true, expr = true }
  km("n", "<leader>cj", f(single.chuck_down, "chuck"), opts)
  km("n", "<leader>ck", f(single.chuck_up, "chuck"), opts)

  km("n", "<leader>cJ", f(single.grab_down, "grab"), opts)
  km("n", "<leader>c<C-j>", f(section.grab_down, "grab"), opts)
  km("n", "<leader>c<C-k>", f(section.grab_up, "grab"), opts)
  km("n", "<leader>cc<C-j>", f(section.copy_grab_down, "grab"), opts)
  km("n", "<leader>cc<C-k>", f(section.copy_grab_up, "grab"), opts)
  km("n", "<leader>cK", f(single.grab_up, "grab"), opts)
  km("n", "<leader>ccj", f(single.copy_chuck_down, "chuck"), opts)
  km("n", "<leader>cck", f(single.copy_chuck_up, "chuck"), opts)
  km("n", "<leader>ccJ", f(single.copy_grab_down, "grab"), opts)
  km("n", "<leader>ccK", f(single.copy_grab_up, "grab"), opts)
  km("n", "<leader>cl", f(single.chuck_fwd, "chuck"), opts)

  km("v", "<leader>cj", f(single.vis_chuck_down, "chuck"), opts)
  km("v", "<leader>ck", f(single.vis_chuck_up, "chuck"), opts)
  km("v", "<leader>ccj", f(single.vis_copy_chuck_down, "chuck"), opts)
  km("v", "<leader>cck", f(single.vis_copy_chuck_up, "chuck"), opts)

  km("x", "<leader>cj", f(single.vis_chuck_down, "chuck"), opts)
  km("x", "<leader>ck", f(single.vis_chuck_up, "chuck"), opts)
  km("x", "<leader>ccj", f(single.vis_copy_chuck_down, "chuck"), opts)
  km("x", "<leader>cck", f(single.vis_copy_chuck_up, "chuck"), opts)
end

return M
