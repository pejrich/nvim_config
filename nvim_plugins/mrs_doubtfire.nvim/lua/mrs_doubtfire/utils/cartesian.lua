local M = {}

function M.distance(x, y, x2, y2)
  return math.sqrt(math.pow(x - x2, 2) + math.pow(y - y2, 2))
end

return M
