local M = {}
M.__index = M

---@class State
---@field lines string[]
---@field index number
---@field count integer
---@field dir "up"|"down"
---@field is_copy boolean
---@field callbacks table<integer, function>
---@field tick_count integer

---@return State
function M:new(params)
  self.__index = self
  return setmetatable(params or {}, self)
end

function M:run()
  self.tick_count = self.tick_count or 0

  if self.callbacks[self.tick_count] then
    self.callbacks[self.tick_count](self)
  end
end

return M
