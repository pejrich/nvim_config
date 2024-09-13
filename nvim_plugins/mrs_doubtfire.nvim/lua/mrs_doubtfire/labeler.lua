local M = {}

function M.label_matches(matches)
  local map = M.grid_key_map()
  local labels = {}

  local dists = MD.c.enum.flat_map(matches, function(i)
    return MD.c.enum.map(M.find_closest(map, i.cursor_position[2], i.cursor_position[1]), function(x)
      x.match = i
      return x
    end)
  end)
  dists = MD.c.enum.sort_by(dists, function(d)
    return d.distance
  end)
  dists = MD.c.enum.reduce(dists, { {}, {} }, function(i, acc)
    if acc[1][i.x .. i.y] == nil and acc[2][i.match.id] == nil then
      acc[1][i.x .. i.y] = i
      acc[2][i.match.id] = i.x .. i.y
    end
    return acc
  end)[1]
  for k, v in pairs(dists) do
    v.match.label = k
  end
  -- dists = MD.c.enum.uniq_by(dists, function(d)
  --   return d.match.id
  -- end)
  -- MD.c.enum.each(dists, function(i)
  --   i.match.label = i.x .. i.y
  -- end)
  -- for _, i in ipairs(matches) do
  --   local closest = M.find_closest(map, i.cursor_position[2], i.cursor_position[1])
  --   closest.match = i
  --   local prev = labels[closest.x .. closest.y]
  --   if prev == nil or prev.distance > closest.distance then
  --     labels[closest.x .. closest.y] = closest
  --   end
  -- end
  -- for k, v in pairs(labels) do
  --   v.match.label = k
  -- end
end

function M.grid_key_map()
  local grid = MD.c.ui.buffer_window_bounds()
  local qp = MD.c.grid.distribute_Q_P(grid.minX, grid.maxX)
  local al = MD.c.grid.distribute_A_L(grid.minY, grid.maxY)
  local map = {}
  for k, v in pairs(qp) do
    for k2, v2 in pairs(al) do
      map[k .. k2] = { v, v2 }
      map[k] = { v, nil }
      map[k2] = { nil, v2 }
    end
  end
  return map
end

function M.find_closest(map, x, y)
  local dist = 99999999
  local dists = { 9999999, 99999999, 9999999 }
  local coords = { nil, nil, nil }
  local coord = { nil, nil }
  for _, i in ipairs(MD.c.keys.HORIZ) do
    for _, j in ipairs(MD.c.keys.VERT) do
      local c = map[i .. j]
      local d = MD.c.cartesian.distance(c[1], c[2], x, y)
      local index = MD.c.enum.find_index(dists, function(val)
        return d < val
      end)
      if index then
        dists[index] = d
        coords[index] = { i, j }
      end
    end
  end
  local zipped = MD.c.enum.zip(dists, coords, function(d, c)
    return { x = c[1], y = c[2], distance = d }
  end)
  return MD.c.enum.sort_by(zipped, function(i)
    return i.distance
  end)
end
-- P(MD.c.ui.window_bounds())
-- P(MD.c.ui.visible_bounds())
-- P(MD.c.locator.grid_to_buf())
-- P(M.label_matches(nil))
-- P(M.find_closest(M.label_matches(nil), 40, 41))
return M
