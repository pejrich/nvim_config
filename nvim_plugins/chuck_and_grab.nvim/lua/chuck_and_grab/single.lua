local M = {}

local utils = require("chuck_and_grab.utils")
local highlight = require("chuck_and_grab.highlight")
local function curridx()
  return utils.current_line_idx()
end

function M.chuck_down(count, line, copy, func)
  line = line or curridx()
  copy = copy or false
  vim.schedule(function()
    line = line or curridx()
    highlight.highlight_path(count, line, copy or false, function()
      if func then
        func()
      end
      require("chuck_and_grab").finished()
    end)
  end)
end

function M.chuck_up(count, line, copy, func)
  line = line or curridx()
  copy = copy or false
  if type(line) == "number" then
    count = math.min(count, line)
  else
    count = math.min(count, line[1])
  end
  vim.schedule(function()
    count = count * -1
    line = line or curridx()
    highlight.highlight_path(count, line, copy or false, function()
      if func then
        func()
      end
      require("chuck_and_grab").finished()
    end)
  end)
end

function M.vis_chuck_up(count)
  local start = vim.fn.getpos("'<'")[2] - 1
  local stop = vim.fn.getpos("'>'")[2]
  M.chuck_up(count, { start, stop }, false)
end
function M.vis_chuck_down(count)
  local start = vim.fn.getpos("'<'")[2] - 1
  local stop = vim.fn.getpos("'>'")[2]
  M.chuck_down(count, { start, stop }, false)
end
function M.grab_up(count)
  local int = math.max(count, 1)
  M.chuck_down(int, curridx() - int, false)
end

function M.grab_down(count)
  M.chuck_up(count, curridx() + count, false)
end

function M.copy_chuck_down(count)
  M.chuck_down(count, curridx(), true)
end

function M.vis_copy_chuck_down(count)
  local start = vim.fn.getpos("'<'")[2] - 1
  local stop = vim.fn.getpos("'>'")[2]
  M.chuck_down(count, { start, stop }, true)
end
function M.copy_chuck_up(count)
  M.chuck_up(count, curridx(), true)
end
function M.copy_grab_up(count)
  M.chuck_down(count, curridx() - count, true, function()
    vim.cmd("norm! k")
  end)
end

function M.vis_copy_chuck_up(count)
  local start = vim.fn.getpos("'<'")[2] - 1
  local stop = vim.fn.getpos("'>'")[2]
  M.chuck_up(count, { start, stop }, true)
end
function M.copy_grab_down(count)
  M.chuck_up(count, curridx() + count, true, function()
    vim.cmd("norm! k")
  end)
end

return M
