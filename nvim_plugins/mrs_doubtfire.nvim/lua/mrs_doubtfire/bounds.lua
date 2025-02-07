local M = {}

-- Create a new bounds object
function M.new(bounds)
  bounds = bounds or {}
  local self = {
    _minX = bounds.minX or 0,
    _minY = bounds.minY or 0,
    _maxX = bounds.maxX or 0,
    _maxY = bounds.maxY or 0,
  }

  -- Define getters and setters
  local mt = {
    __index = function(t, k)
      if k == "minX" then
        return t._minX
      elseif k == "maxX" then
        return t._maxX
      elseif k == "minY" then
        return t._minY
      elseif k == "maxY" then
        return t._maxY
      elseif k == "midX" then
        return t._minX + math.ceil((t._maxX - t._minX) / 2)
      elseif k == "midY" then
        return t._minY + math.ceil((t._maxY - t._minY) / 2)
      else
        return M[k]
      end
    end,

    __newindex = function(t, k, v)
      if k == "minX" then
        t._minX = v
      elseif k == "maxX" then
        t._maxX = v
      elseif k == "minY" then
        t._minY = v
      elseif k == "maxY" then
        t._maxY = v
      else
        rawset(t, k, v)
      end
    end,
  }

  return setmetatable(self, mt)
end

-- Helper method to get all bounds as a table
function M:getBounds()
  return {
    minX = self.minX,
    maxX = self.maxX,
    minY = self.minY,
    maxY = self.maxY,
    midX = self.midX,
    midY = self.midY,
  }
end

-- Helper method to update all bounds at once
function M:setBounds(bounds)
  if bounds.minX then
    self.minX = bounds.minX
  end
  if bounds.maxX then
    self.maxX = bounds.maxX
  end
  if bounds.minY then
    self.minY = bounds.minY
  end
  if bounds.maxY then
    self.maxY = bounds.maxY
  end
end

return M
