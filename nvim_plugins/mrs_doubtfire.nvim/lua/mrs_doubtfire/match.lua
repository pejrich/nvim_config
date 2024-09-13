local M = {}
M.__index = M
-- function(t, k)
--   if k == "cursor_position" then
--     return M._cursor_position(t)
--   else
--     M[k](t)
--   end
-- end

local id_count = 0
local function get_id()
  id_count = id_count + 1
  return id_count
end

---@return integer
local function _score(self)
  local max = math.max(self.stop, MD.c.enum.max_value(self.forward_matches, function(m)
    return m.stop
  end) or self.stop)
  local min = math.min(self.start, MD.c.enum.min_value(self.backward_matches, function(m)
    return m.start
  end) or self.start)
  return max - min
end

---@return [integer, integer]
local function _cursor_position(self)
  return { self.line_number + 1, self.start }
end
---@return Match
function M.new(map)
  local meta = setmetatable({}, M)
  meta.__index = function(t, k)
    if k == "cursor_position" then
      return _cursor_position(t)
    elseif k == "score" then
      return _score(t)
    end
  end
  local self = setmetatable({}, meta)
  self.id = get_id()
  self.start = map.start
  self.stop = map.stop
  self.text = map.text
  self.line_number = map.line_number
  self.index_in_line = map.index_in_line
  self.forward_matches = map.forward_matches or {}
  self.backward_matches = map.backward_matches or {}
  -- self.cursor_position = _cursor_position(self)
  return self
end
setmetatable(M, { __call = M.new })

return M
