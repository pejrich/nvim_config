local Pos = {}
Pos.__index = Pos
Pos.__le = function(a, b)
  if a[1] == b[1] and a[2] == b[2] then
    return true
  end
  if a[1] < b[1] then
    return true
  elseif a[1] > b[1] then
    return false
  else
    return a[2] < b[2]
  end
end
Pos.__eq = function(a, b)
  return a[1] == b[1] and a[2] == b[2]
end
function Pos:__tostring()
  return "{" .. self.x .. ", " .. self.y .. "}"
end
Pos.__lt = function(a, b)
  if a[1] < b[1] then
    return true
  elseif a[1] > b[1] then
    return false
  else
    return a[2] < b[2]
  end
end

function Pos.new(coord)
  if coord.is_pos then
    return coord
  end
  local self = setmetatable({}, Pos)
  self.is_pos = true
  self.x = coord[2]
  self.y = coord[1]
  self.line = coord[1]
  self.row = coord[1]
  self.col = coord[2]
  self[1] = coord[1]
  self[2] = coord[2]
  return self
end
function Pos:go_to()
  vim.api.nvim_win_set_cursor(0, { self.line + 1, self.col })
end
_G.Pos = Pos
return Pos
