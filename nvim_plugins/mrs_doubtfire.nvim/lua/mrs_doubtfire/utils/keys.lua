local M = {}

M.replace_termcode = function(str)
  return vim.api.nvim_replace_termcodes(str, true, false, true)
end
M.HORIZ = { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }
M.VERT = { "A", "S", "D", "F", "G", "H", "J", "K", "L" }
M.LOOKUP = {}
for i, j in ipairs(M.HORIZ) do
  M.LOOKUP[j] = { index = i, dir = "horiz", char = j }
end

for i, j in ipairs(M.VERT) do
  M.LOOKUP[j] = { index = i, dir = "vert", char = j }
end
---@class CharInfo
---@field index integer
---@field dir "vert" | "horiz"
---@field char string
---@field col integer?
---@field line integer?

---@return CharInfo?
function M.lookup_key(key)
  return M.LOOKUP[key:upper()]
end
M.BS = M.replace_termcode("<bs>")
M.ESC = M.replace_termcode("<esc>")
M.CR = M.replace_termcode("<cr>")

M.CTRL_TO_CHAR_TABLE = {}
for _, i in ipairs(M.HORIZ) do
  M.CTRL_TO_CHAR_TABLE["<C-" .. i .. ">"] = i
end
for _, i in ipairs(M.VERT) do
  M.CTRL_TO_CHAR_TABLE["<C-" .. i .. ">"] = i
end
M.KEYCODE_TO_CTRL_TABLE = {}

for k, _ in pairs(M.CTRL_TO_CHAR_TABLE) do
  M.KEYCODE_TO_CTRL_TABLE[M.replace_termcode(k)] = k
end

function M.keycode_to_char(keycode)
  local ctrl = M.KEYCODE_TO_CTRL_TABLE[keycode]
  return M.CTRL_TO_CHAR_TABLE[ctrl]
end
return M
