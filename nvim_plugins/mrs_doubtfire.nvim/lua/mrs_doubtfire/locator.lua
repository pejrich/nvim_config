local M = {}

---@param state State
function M.reduce(state)
  if state.gridpress.horiz == nil and state.gridpress.vert == nil then
    return
  end
  local gtb = M.grid_to_buf()
  local x = state.gridpress.horiz and gtb.horiz[state.gridpress.horiz.char] or nil
  local y = state.gridpress.vert and gtb.vert[state.gridpress.vert.char] or nil
  local matches = state:all_match_positions()
  local closest = M.find_closest(matches, x, y)
  local map = {}
  for _, i in ipairs(closest) do
    map[i.match_id] = true
  end
  M.filter_state_matches(state, map)
end

---@param state State
---@param map table<integer, boolean>
function M.filter_state_matches(state, map)
  state.lines = MD.c.enum.map(state.lines, function(line)
    line.matches = MD.c.enum.filter(line.matches, function(m)
      return map[m.id]
    end)
    return line
  end)
  state.lines = MD.c.enum.filter(state.lines, function(line)
    return #line.matches > 0
  end)
end

---@param matches MatchPOS[]
---@param x integer?
---@param y integer?
---@return MatchPOS[]
function M.find_closest(matches, x, y)
  local xspread = M.spread(matches, "horiz")
  local yspread = M.spread(matches, "vert")
  local spread = (xspread + yspread) / 2 / 10
  if x == nil then
    spread = xspread / 10
  end
  if y == nil then
    spread = yspread / 10
  end
  local dist = MD.c.enum.map(matches, function(match)
    return { match, M.distance(match, x, y) }
  end)
  local min = MD.c.enum.min_by(dist, function(val)
    return val[2]
  end)
  local cutoff = (min[2] > 0 and min[2] <= 6) and (min[2] * (1 + (1 / min[2]))) or min[2]
  local filt = MD.c.enum.filter(dist, function(val)
    return val[2] <= cutoff
  end)
  return MD.c.enum.map(filt, function(val)
    return val[1]
  end)
end

---@param match MatchPOS
---@param x integer?
---@param y integer?
---@return number
function M.distance(match, x, y)
  if x and y then
    return MD.c.cartesian.distance(match.x, match.y, x, y)
  elseif x ~= nil then
    return math.abs(match.x - x)
  else
    return math.abs(match.y - y)
  end
end

---@param matches MatchPOS[]
---@param type "horiz" | "vert"
---@return integer
function M.spread(matches, type)
  local key = type == "horiz" and "x" or "y"
  local min = 99999
  local max = -9999
  for _, i in ipairs(matches) do
    if i[key] > max then
      max = i[key]
    end
    if i[key] < min then
      min = i[key]
    end
  end
  return max - min
end

function M.grid_to_buf()
  local bounds = MD.c.ui.buffer_window_bounds()

  return {
    horiz = MD.c.grid.distribute_horiz(bounds.minX, bounds.maxX),
    vert = MD.c.grid.distribute_vert(bounds.minY, bounds.maxY),
  }
end

return M
