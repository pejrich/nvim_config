local M = {}
---@alias Enum any[]

---@param table table
---@return table
M.swap = function(table)
  local ret = {}
  for k, v in pairs(table) do
    ret[v] = k
  end
  return ret
end

---@param start integer
---@param stop integer
---@return integer[]
M.range = function(start, stop)
  local t = {}
  for i = start, stop do
    table.insert(t, i)
  end
  return t
end

M.find_index = function(enum, fun)
  for i, j in ipairs(enum) do
    if fun(j) then
      return i
    end
  end
end

---@param enum Enum
---@param fun function(i: any): boolean
---@return any?
M.find = function(enum, fun)
  local ret = nil
  for _, i in ipairs(enum) do
    if fun(i) then
      ret = i
      break
    end
  end
  return ret
end

---@param enum Enum
---@param fun function(i: any): boolean
---@return Enum
M.drop_while = function(enum, fun)
  local ret = {}
  local dropping = true
  if enum[1] == nil then
    return {}
  end
  for _, i in ipairs(enum) do
    if dropping and fun(i) then
    else
      dropping = false
      table.insert(ret, i)
    end
  end
  return ret
end

---@param enum Enum
---@param fun function(i: any): boolean
---@return Enum
M.take_while = function(enum, fun)
  local ret = {}
  for _, i in ipairs(enum) do
    if fun(i) then
      table.insert(ret, i)
    else
      break
    end
  end
  return ret
end

---@param enum Enum
---@param n integer
---@return Enum
M.drop = function(enum, n)
  for _ = 1, n do
    table.remove(enum, 1)
  end
  return enum
end

---@param enum Enum
---@param n integer
---@return Enum
M.take = function(enum, n)
  local ret = {}
  for i = 1, n do
    table.insert(ret, enum[i])
  end
  return ret
end

---@param enum Enum
---@param fun fun(i: any): any
---@return any
M.max_value = function(enum, fun)
  return M.max(M.map(enum, fun))
end

---@param enum Enum
---@param fun fun(i: any): any
---@return any
M.min_value = function(enum, fun)
  return M.min(M.map(enum, fun))
end

---@param enum Enum
---@return any
M.max = function(enum)
  return M.max_by(enum, function(val)
    return val
  end)
end

---@param enum Enum
---@return any
M.min = function(enum)
  return M.min_by(enum, function(val)
    return val
  end)
end

---@param enum Enum
---@param fun fun(i: any): any
---@return any
M.max_by = function(enum, fun)
  local max = nil
  local max_val = nil
  for _, i in ipairs(enum) do
    local v = fun(i)
    if max == nil or v > max then
      max = v
      max_val = i
    end
  end
  return max_val
end
---@param enum Enum
---@param fun fun(i: any): any
---@return any
M.min_by = function(enum, fun)
  local min = nil
  local min_val = nil
  for _, i in ipairs(enum) do
    local v = fun(i)
    if min == nil or v < min then
      min = v
      min_val = i
    end
  end
  return min_val
end
---@param enum Enum
---@param fun fun(i: any): any
---@return Enum
M.filter = function(enum, fun)
  local ret = {}
  for _, i in ipairs(enum) do
    if fun(i) then
      table.insert(ret, i)
    end
  end
  return ret
end

M.sort_by = function(enum, fun)
  local mapped = M.map(enum, function(i)
    return { i, fun(i) }
  end)
  table.sort(mapped, function(t1, t2)
    return t1[2] < t2[2]
  end)
  return M.map(mapped, function(t)
    return t[1]
  end)
end

---@param table_a Enum
---@param table_b Enum
---@param fun fun(a: any, b: any): any
---@return integer[]
M.zip = function(table_a, table_b, fun)
  local ret = {}
  for k, v in ipairs(table_a) do
    local b = table_b[k]
    if b then
      table.insert(ret, fun(v, b))
    end
  end
  return ret
end

---@param enum Enum
---@return Enum
M.values = function(enum)
  if type(enum) == "table" then
    local ret = {}
    for _, v in pairs(enum) do
      table.insert(ret, M.uniq(v))
    end
    return ret
  else
    return enum
  end
end

---@param enum Enum
---@return Enum
M.flatten = function(enum)
  local ret = {}
  for _, v in ipairs(enum) do
    if type(v) == "table" then
      for _, v2 in ipairs(M.flatten(v)) do
        table.insert(ret, v2)
      end
    else
      table.insert(ret, v)
    end
  end
  return ret
end
---@param enum Enum
---@return Enum
M.uniq = function(enum)
  if type(enum) ~= "table" then
    return enum
  end
  local t = {}
  for _, i in pairs(enum) do
    t[table.concat(M.flatten(M.values(i)))] = i
  end
  local ret = {}
  for _, k in pairs(t) do
    table.insert(ret, k)
  end
  return ret
end

M.uniq_by = function(enum, fun)
  local ret = {}
  local vals = {}
  for _, i in ipairs(enum) do
    local val = fun(i)
    if vals[val] == nil then
      table.insert(ret, i)
      vals[val] = true
    end
  end
  return ret
end

---@param enum Enum
---@return Enum
M.reversed = function(enum)
  local ret = {}
  for i = #enum, 1, -1 do
    table.insert(ret, enum[i])
  end
  return ret
end

---@param enum Enum
---@param to_add any
---@return Enum
M.intersperse = function(enum, to_add)
  local ret = {}
  local tail = table.remove(enum, #enum)
  for _, val in ipairs(enum) do
    table.insert(ret, val)
    table.insert(ret, to_add)
  end
  table.insert(ret, tail)
  return ret
end

---@param enum Enum
---@param fun fun(i: any): any
---@return Enum
M.map = function(enum, fun)
  local ret = {}
  for _, v in ipairs(enum) do
    ret[#ret + 1] = fun(v)
  end
  return ret
end

M.each = function(enum, fun)
  for _, i in ipairs(enum) do
    fun(i)
  end
end

---@param enum Enum
---@param initial any
---@param fun fun(i: any, acc: any): any
---@return any
M.reduce = function(enum, initial, fun)
  local acc = initial
  for _, v in ipairs(enum) do
    acc = fun(v, acc)
  end
  return acc
end

---@param enum Enum
---@return Enum
M.copy = function(enum)
  if type(enum) == "table" then
    local ret = {}
    for k, v in pairs(enum) do
      ret[k] = M.copy(v)
    end
    return ret
  else
    return enum
  end
end

---@param enum Enum
---@param index integer
---@return [Enum, Enum]
M.split_at = function(enum, index)
  local h = {}
  for _ = 1, index do
    table.insert(h, table.remove(enum, 1))
  end
  return { h, enum }
end

M.flat_map = function(enum, fun)
  local ret = {}
  for _, i in ipairs(enum) do
    for _, j in ipairs(fun(i)) do
      table.insert(ret, j)
    end
  end
  return ret
end

return M
