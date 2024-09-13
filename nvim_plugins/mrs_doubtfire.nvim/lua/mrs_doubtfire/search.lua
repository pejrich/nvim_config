local enum = require("mrs_doubtfire.utils.enum")
local M = {}

function M.insens(char)
  if char then
    return "[" .. char:upper() .. char:lower() .. "]"
  else
    return ""
  end
end

function M.wrap(str)
  if str then
    return "(" .. str .. ")"
  else
    return ""
  end
end

function M.iwrap(str)
  return M.wrap(M.insens(str))
end
---@return {target: string, pat: string}
function M.create_pattern(target_keys, forward_keys, backward_keys)
  local t1 = target_keys[1]
  local t2 = target_keys[2]
  local trg_pat = M.wrap(M.insens(t1) .. M.insens(t2))
  local pat = ""
  local bwd = {}
  for _, key in ipairs(enum.reversed(backward_keys)) do
    table.insert(bwd, M.iwrap(key))
  end
  local bwd_pattern = table.concat(enum.intersperse(bwd, "(.-)"))
  pat = pat .. bwd_pattern
  pat = pat .. "(.-)" .. trg_pat .. "(.-)"
  local fwd = {}
  for _, key in ipairs(forward_keys) do
    table.insert(fwd, M.iwrap(key))
  end
  local fwd_pattern = table.concat(enum.intersperse(fwd, "(.-)"))
  pat = pat .. fwd_pattern

  local bwd_pat = "^(.*)" .. bwd_pattern .. ".-$"
  local fwd_pat = "^(.-)" .. fwd_pattern .. ".*$"

  local val = { target = trg_pat, pattern = pat, forward_pattern = fwd_pat, backward_pattern = bwd_pat }
  return val
end
function M.line_is_match(line, pat)
  return line:match(pat.pattern) ~= nil
end
local function extract_matches(t, index)
  local ret = {}
  local is_match = true
  local count = index
  for _, i in ipairs(t) do
    if is_match then
      table.insert(ret, { start = count, stop = count + i:len() - 1, text = i })
      count = count + i:len()
      is_match = false
    else
      count = count + i:len()
      is_match = true
    end
  end

  return ret
end
function M.process_line(line, pat, bounds)
  local line_text = line.text:sub(bounds.minX + 1, bounds.maxX + 1)
  local matches = {}
  for index, match in line_text:gmatch("()" .. pat.target .. "") do
    index = index + bounds.minX
    local before = line.text:sub(0, index - 1)
    local after = line.text:sub(index + match:len())
    local bwd = { before:find(pat.backward_pattern) }
    local fwd = { after:find(pat.forward_pattern) }
    if #bwd > 0 and #fwd > 0 then
      local bwd_start = table.remove(bwd, 1)
      table.remove(bwd, 1)
      local excess = table.remove(bwd, 1)
      local bwd_matches = extract_matches(bwd, bwd_start + excess:len() - 1)
      local fwd_start = table.remove(fwd, 1)
      table.remove(fwd, 1)
      local fexcess = table.remove(fwd, 1)
      local fwd_matches = extract_matches(fwd, index + fexcess:len() + 1)

      local res = MD.c.match.new({
        line_number = line.index,
        start = index - 1,
        stop = index + match:len() - 2,
        forward_matches = fwd_matches,
        backward_matches = bwd_matches,
      })
      table.insert(matches, res)
    end
  end
  return matches
end

return M
