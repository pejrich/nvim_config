local M = {}
local L = {}
local utils = require("chuck_and_grab.utils")

local active_layer = nil
local layer_pos = nil
local layer_pressed_key = nil
L.final = function() end
function M.init()
  layer_pos = utils.curpos()
  active_layer = Layers.mode.new()
  active_layer:keymaps({
    n = {
      {
        "j",
        function()
          M.layer_key_pressed("j")
        end,
        { desc = "Follow down" },
      },
      {
        "k",
        function()
          M.layer_key_pressed("k")
        end,
        { desc = "Follow up" },
      },
    },
  })
  active_layer:activate()
  return function(count, final)
    M.deactivate_layer(count, final)
  end
end
function M.deactivate_layer(count, final)
  final = final or false
  if layer_pressed_key == "k" and layer_pos ~= nil then
    pcall(function()
      vim.api.nvim_win_set_cursor(0, { layer_pos[1] - count, layer_pos[2] })
      final = true
    end)
  elseif layer_pressed_key == "j" and layer_pos ~= nil then
    pcall(function()
      vim.api.nvim_win_set_cursor(0, { layer_pos[1] + count, layer_pos[2] })
      final = true
    end)
  else
    if not final then
      L.final = function()
        L.final = function() end
        M.deactivate_layer(count, true)
      end
      vim.defer_fn(function()
        L.final()
      end, 1000)
    end
  end
  if final then
    layer_pressed_key = nil
    layer_pos = nil
    if active_layer then
      active_layer:deactivate()
      active_layer = nil
    end
  end
end
function M.layer_key_pressed(key)
  layer_pressed_key = key
  L.final()
end

return M
