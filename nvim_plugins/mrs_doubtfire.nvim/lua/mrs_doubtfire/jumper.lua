local M = {}
local jumps = {}
local current_jump = 0
local ns = vim.api.nvim_create_namespace("mrs_doubtfire.jumplist")
M.new_jump = function(cursor_position)
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local extmark = vim.api.nvim_buf_set_extmark(
    buf,
    ns,
    cursor_position[1] - 1,
    cursor_position[2],
    { end_col = cursor_position[2] + 1 }
  )
  table.insert(jumps, { buf = buf, win = win, extmark = extmark })
  current_jump = #jumps
  vim.api.nvim_win_set_cursor(win, cursor_position)
end

--- This just adds the current cursor position to the jump list so it can be jumped back to later
M.jump_to_current = function()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local extmark = vim.api.nvim_buf_set_extmark(buf, ns, cursor[1] - 1, cursor[2], { end_col = cursor[2] + 1 })
  table.insert(jumps, { buf = buf, win = win, extmark = extmark })
  current_jump = #jumps
  vim.api.nvim_win_set_cursor(win, cursor)
end

M.jump_to_prev = function(n)
  current_jump = math.max(1, math.min(#jumps, current_jump + n))
  local j = jumps[current_jump]
  if j then
    local ext = vim.api.nvim_buf_get_extmark_by_id(j.buf, ns, j.extmark, { details = false, hl_name = false })
    vim.api.nvim_win_set_buf(j.win, j.buf)
    vim.api.nvim_win_set_cursor(j.win, { ext[1] + 1, ext[2] })
  end
  M.jump_display({ current = current_jump, total = #jumps })
end

M.cleanup = function()
  for _, i in ipairs(jumps) do
    local ext = vim.api.nvim_buf_get_extmark_by_id(i.buf, ns, i.extmark, { details = false, hl_name = false })
    vim.api.nvim_buf_set_extmark(i.buf, ns, ext[1], ext[2], { id = i.extmark, hl_group = nil, end_col = ext[2] })
  end
end

M.set_jump_mode = function()
  for _, i in ipairs(jumps) do
    local ext = vim.api.nvim_buf_get_extmark_by_id(i.buf, ns, i.extmark, { details = false, hl_name = false })
    vim.api.nvim_buf_set_extmark(
      i.buf,
      ns,
      ext[1],
      ext[2],
      { id = i.extmark, hl_group = "MD_PreferredTargetMatch", end_col = ext[2] + 1 }
    )
  end
end

M.jump_display = function(info)
  -- local diff = 60 * ((info.current - 1) / info.total)
  -- local after = math.floor(60 - diff)
  -- local before = math.ceil(diff)
  -- local h = (info.current == 1) and "|1|" or " 1 "
  -- local t = (info.current == info.total) and ("|" .. info.total .. "|") or (" " .. info.total .. " ")
  -- local current = (info.current > 1 and info.current < info.total) and ("|" .. info.current .. "|") or "----"
  local disp = ""
  for i = 1, info.total do
    local l = "--"
    local r = "--"
    if i == 1 then
      l = ""
    end
    if i == info.total then
      r = ""
    end
    if i == info.current then
      disp = disp .. l .. "|" .. i .. "|" .. r
    else
      disp = disp .. l .. " " .. i .. " " .. r
    end
  end
  local display = string.rep(" ", 5) .. disp .. string.rep(" ", 5)
  MD.c.prompt.set(display)
end
return M
