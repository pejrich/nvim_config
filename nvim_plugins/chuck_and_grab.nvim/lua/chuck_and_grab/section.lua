local M = {}
local single = require("chuck_and_grab.single")
local utils = require("chuck_and_grab.utils")
local config = require("chuck_and_grab.config")

function M.grab_up(count, copy)
  copy = copy or false
  local pos = utils.curpos()
  local line = pos[1] - count - 1
  local section = M.select_section({ line, line }, "up")
  P(section)
  if section then
    vim.api.nvim_buf_clear_namespace(0, config.ns, 0, -1)
    local rem = section[2] + 1 - section[1]
    config.multi_count = math.abs(section[2] - section[1])
    M._chuck_section("chuck_down", pos[1] - section[2] + 1, section[1] + 1, copy, rem)
  end
end
function M.grab_down(count, copy)
  copy = copy or false
  local pos = utils.curpos()
  local line = pos[1] + count - 1
  local section = M.select_section({ line, line }, "down")
  P(section)
  if section then
    vim.api.nvim_buf_clear_namespace(0, config.ns, 0, -1)
    local rem = section[2] + 1 - section[1]
    config.multi_count = math.abs(section[2] - section[1])
    M._chuck_section("chuck_up", section[2] - pos[1] + 1, section[2] + 1, copy, rem)
  end
end
function M.copy_grab_down(count)
  M.grab_down(count, true)
end
function M.copy_grab_up(count)
  M.grab_up(count, true)
end
function M._chuck_section(type, count, line, copy, rem)
  if rem == 0 then
    config.multi_count = 1
    return
  end
  if type == "chuck_up" then
    single._chuck_up(count, line, copy, function()
      rem = rem - 1
      M._chuck_section(type, count, line, copy, rem)
    end)
  else
    if copy then
      -- When copying since the line doesn't move from it's current location, we can't act on the same line each time
      -- and must instead increment the line by 1 for each iteration
      single._chuck_down(count, line, copy, function()
        rem = rem - 1
        M._chuck_section(type, count, line + 1, copy, rem)
      end)
    else
      single._chuck_down(count, line, copy, function()
        rem = rem - 1
        M._chuck_section(type, count, line, copy, rem)
      end)
    end
  end
end
function M.select_section(section, dir)
  vim.api.nvim_buf_clear_namespace(0, config.ns, 0, -1)
  vim.api.nvim_buf_set_extmark(0, config.ns, section[1], 0, { end_row = section[2], line_hl_group = "IncSearch" })
  local char = utils.getchar()
  local esc = 27
  local j = 106
  local k = 107
  if char == j and dir == "down" then
    return M.select_section({ section[1], section[2] + 1 }, dir)
  elseif char == k and dir == "up" then
    return M.select_section({ section[1] - 1, section[2] }, dir)
  elseif char == k and dir == "down" then
    return M.select_section({ section[1], section[2] - 1 }, dir)
  elseif char == j and dir == "up" then
    return M.select_section({ section[1] + 1, section[2] }, dir)
  elseif char == esc then
    vim.api.nvim_buf_clear_namespace(0, config.ns, 0, -1)
    return nil
  else
    return section
  end
end

return M
