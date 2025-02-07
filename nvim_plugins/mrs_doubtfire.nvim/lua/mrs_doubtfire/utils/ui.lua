local M = {}

---@return number
function M.line_width(lnum)
  return tonumber(vim.api.nvim_exec("echo strdisplaywidth(getline(" .. lnum .. ", " .. lnum .. ")[0])", true)) or 0
end
---@return number
function M.top_row()
  return tonumber(vim.api.nvim_exec("echo line('w0')", true)) or 0
end
---@return number
function M.bottom_row()
  return tonumber(vim.api.nvim_exec("echo line('w$')", true)) or 0
end
---@return number
function M.left_col()
  return tonumber(vim.api.nvim_exec("echo winsaveview()['leftcol']", true)) or 0
end
---@return number
function M.right_col()
  return tonumber(vim.api.nvim_exec("echo max(map(getline(1, '$'), 'strdisplaywidth(v:val)'))", true)) or 0
end
---@return [ integer, integer ]
function M.row_range()
  return { M.top_row(), M.bottom_row() }
end

---@return {minY: number, maxY: number, minX: number, maxX: number, midX: number, midY: number}
function M.visible_bounds()
  local minY = M.top_row() - 1
  local maxY = M.bottom_row()
  local minX = M.left_col()
  local maxX = M.right_col()
  return MD.c.bounds.new({ minY = minY, maxY = maxY, minX = minX, maxX = maxX })
end

function M.bounds(matches)
  local vals = { minX = 10000, maxX = -10000, minY = 100000, maxY = -100000 }
  for k, v in pairs(matches) do
    vals.minX = math.min(vals.minX, v.pos[1])
    vals.maxX = math.max(vals.maxX, v.pos[1])
    vals.minY = math.min(vals.minY, v.pos[2])
    vals.maxY = math.max(vals.maxY, v.pos[2])
  end
end
---Returns the dimensions of the window as well as the bottom line
---A buffer can be smaller than the window
---@return {height: number, width: number, botline: number}
function M.window_bounds()
  local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  return { height = info.height, width = info.width, botline = info.botline }
end

---This returns min/max X/Y coordinates for the whole window relative to the buffer.
---Because it covers the whole window, while the points are buffer relative, they're not neccessarily all valid buffer locations
function M.buffer_window_bounds()
  local buf_bounds = M.visible_bounds()
  local win_bounds = M.window_bounds()
  return {
    minX = buf_bounds.minX,
    minY = buf_bounds.minY,
    maxX = buf_bounds.minX + win_bounds.width,
    maxY = buf_bounds.minY + win_bounds.height,
    height = win_bounds.height,
    width = win_bounds.width,
    botline = win_bounds.botline,
  }
end
function M.is_ctrl_key(state, key)
  M.bounds(state.results)
  local ctrl = M.ctrlkeys[key]
  if ctrl then
    state.ctrl_keys = state.ctrl_keys or {}
    table.insert(state.ctrl_keys, ctrl)
    return true
  end
end
return M
