local M = {}

local function split(str, delim)
  local t = {}
  for str2 in string.gmatch(str, "([^" .. delim .. "]+)") do
    table.insert(t, str2)
  end
  return t
end
local function trim(str)
  return string.gsub(str, "^%s*(.-)%s*$", "%1")
end
local function yank_to_clipboard(str)
  vim.fn.setreg('"', str)
  vim.fn.setreg("1", str)
  vim.fn.setreg("0", str)
  vim.fn.setreg("*", str)
  vim.fn.setreg("+", str)
end
-- local ARG_DELIMITERS = { ",", "[", "]", "(", ")", "{", "}", '"', "'" }
function M.remove_function_arg(int)
  int = math.max(int, 1)
  local line = vim.api.nvim_get_current_line()
  local _, _, match, match2, match3 = (line):find("^(.-)(%b())(.-)$")
  local m = match2:match("%((.-)%)")
  local args = split(m, ",")
  local arg_to_delete = args[int]
  yank_to_clipboard(arg_to_delete)
  table.remove(args, int)
  local new_args = "(" .. trim(table.concat(args, ",")) .. ")"
  vim.api.nvim_set_current_line(match .. new_args .. match3)
end

return M
