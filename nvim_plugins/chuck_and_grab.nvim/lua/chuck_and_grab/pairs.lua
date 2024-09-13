local M = {}

local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'", ["<"] = ">" }
local bracket = { "%b()", "%b[]", "%b{}", "%b<>" }
local bracket_sing = { '%b""', "%b''" }
function M.is_pair(str, str2)
  local x = pairs[str]
  return x and (x == (str2 or x))
end
function M.outer_pair(str)
  local pos
  for _, i in ipairs(bracket) do
    local a, b = str:find(i)
    if a and (pos == nil or a < pos[1]) then
      pos = { a, b, i }
    end
  end
  return pos
end

return M
