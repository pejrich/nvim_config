local M = {}

---@return integer
function M.unix_timestamp()
  return os.time(os.date("!*t"))
end

---@param char string
---@param pos [integer, integer]
---@param count integer
---@return [integer, integer]?
function M.find_fwd(char, pos, count)
  count = count or 1
  local buflines = tonumber(vim.api.nvim_exec2("echo line('$')", { output = true }).output)
  if pos[1] == buflines then
    return nil
  end
  local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
  line = line:sub(pos[2] + 1, #line)
  local result = { line:find("^[^" .. vim.pesc(char) .. "]*()" .. vim.pesc(char)) }
  if #result > 0 then
    local ret = { pos[1], result[3] + pos[2] }
    if count == 1 then
      return ret
    else
      return M.find_fwd(char, { ret[1], ret[2] }, count - 1)
    end
  else
    return M.find_fwd(char, { pos[1] + 1, 0 }, count)
  end
end

---@param char string
---@param pos [integer, integer]
---@param count integer
---@return [integer, integer]?
function M.find_back(char, pos, count)
  count = count or 1
  if pos[1] == 0 then
    return nil
  end
  if pos[2] == 0 then
    if pos[1] == 0 then
      return nil
    else
      local line = vim.api.nvim_buf_get_lines(0, pos[1] - 2, pos[1] - 1, false)[1]
      local result = { line:find("()" .. vim.pesc(char) .. "[^" .. vim.pesc(char) .. "]*$") }
      if #result > 0 then
        local ret = { pos[1] - 1, result[3] }
        if count == 1 then
          return ret
        else
          return M.find_back(char, { ret[1], math.max(ret[2] - 1, 0) }, count - 1)
        end
      else
        return M.find_back(char, { pos[1] - 1, 0 }, count)
      end
    end
  else
    local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]:sub(1, pos[2])
    local result = { line:find("()" .. vim.pesc(char) .. "[^" .. vim.pesc(char) .. "]*$") }
    if #result > 0 then
      local ret = { pos[1], result[3] }
      if count == 1 then
        return ret
      else
        return M.find_back(char, { ret[1], math.max(ret[2] - 1, 0) }, count - 1)
      end
    else
      return M.find_back(char, { pos[1], 0 }, count)
    end
  end
end
---@return number
function M.top_row()
  return tonumber(vim.api.nvim_exec2("echo line('w0')", { output = true }).output) or 0
end
---@return number
function M.bottom_row()
  return tonumber(vim.api.nvim_exec2("echo line('w$')", { output = true }).output) or 0
end
---@return number
function M.left_col()
  return tonumber(vim.api.nvim_exec2("echo winsaveview()['leftcol']", { output = true }).output) or 0
end
---@return number
function M.right_col()
  return tonumber(vim.api.nvim_exec2("echo max(map(getline(1, '$'), 'strdisplaywidth(v:val)'))", { output = true }).output) or 0
end
---@return [ integer, integer ]
function M.row_range()
  return { M.top_row(), M.bottom_row() }
end

---@return {minY: number, maxY: number, minX: number, maxX: number,}
function M.visible_bounds()
  local start = M.top_row()
  local stop = M.bottom_row()
  local minX = M.left_col()
  local maxX = M.right_col()
  return { minY = start - 1, maxY = stop, minX = minX, maxX = maxX }
end
---
---@param string string
---@return string
function M.esc_codes(string)
  return vim.api.nvim_replace_termcodes(string, true, true, true)
end

---@return [integer, integer]
function M.cur_pos()
  return vim.api.nvim_win_get_cursor(0)
end

---@return string
function M.cur_line()
  local pos = M.cur_pos()
  return vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
end

---@return string[]
function M.cur_lines(before, after)
  before = before or 0
  after = after or 0
  local pos = M.cur_pos()
  return vim.api.nvim_buf_get_lines(0, pos[1] - 1 + before, pos[1] + after, false)
end

---@param before integer
---@param after integer
---@param text string
function M.replace_lines(before, after, text)
  local pos = M.cur_pos()
  vim.api.nvim_buf_set_lines(0, pos[1] - 1 + before, pos[1] + after, false, text)
end

---@param line integer
---@return integer
function M.line_width(line)
  line = line or M.cur_pos()[1]
  local l = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  return l == nil and 0 or #l
end

local pats = { "[a-zA-Z0-9_.]+%b()", "[a-zA-Z0-9_.]+%b[]", "%%%b{}", "%b{}", "[a-zA-Z0-9._]+" }
function M.remove_pipe_str(t)
  local str = table.concat(t, "\n")
  local val
  for _, i in ipairs(pats) do
    val = { (str):find("%s*()" .. i .. "()%s+|>%s+()[^%(]+%(()[^,%)]*()[,%)]") }
    if #val > 0 then
      break
    end
  end
  local tail = str:sub(val[6], #str)
  local delim = tail:find("^%s*%)") and "" or ", "
  return str:sub(1, val[3] - 1) .. str:sub(val[5], val[6] - 1) .. str:sub(val[3], val[4] - 1) .. delim .. str:sub(val[6], #str)
end

-- local t = { "   z(x)", "  |> func(a, b)" }

-- local t2 = { "   func(z(x), a, b)" }
-- local t2 = { "   func(zx, a, b)" }
-- local t2 = { "   z(x) |> thing()" }
-- local t2 = { "   z(x)" }
function M.add_pipe_str(t)
  local str = table.concat(t)
  local val
  for _, i in ipairs(pats) do
    val = { str:find("()%s*()[A-Za-z0-9._]+%(()" .. i .. "(),*%s*()") }
    if #val > 0 then
      break
    end
  end
  -- val = #val > 0 and val or { str:find("^()%s+()[^%(]+%(()[^%(,]-(),%s()") }
  -- val = #val > 0 and val or { str:find("^()%s+()[^%(]+%(()[^%,]-()()%)") }
  return str:sub(1, val[4] - 1) .. str:sub(val[5], val[6] - 1) .. " |> " .. str:sub(val[4], val[5] - 1) .. str:sub(val[7], #str)
end
function M.expand_ex_function_str(lines)
  -- return str:gsub("\n", " "):gsub(", do: ", " do\n") .. "\nend"
  local prefix = {}
  local line = ""
  local suffix = {}
  local i = 1
  while i <= #lines do
    if lines[i]:find(",$") and lines[i + 1]:find("^%s*do:") then
      line = lines[i] .. lines[i + 1]
    end
  end
  for _, i in ipairs(lines) do
    -- if i:find(",")
  end
end
function M.expand_elixir_function()
  M.expand_ex_function_str(M.cur_lines(-2, 2))
end
function M.remove_pipe()
  local line = M.cur_line()
  local text = M.remove_pipe_str(M.cur_lines(-1, 0))
  M.replace_lines(-1, 0, vim.split(text, "\n"))
end
function M.add_pipe()
  local text = M.add_pipe_str(M.cur_lines(0, 0))
  M.replace_lines(0, 0, vim.split(text, "\n"))
end

vim.keymap.set("n", "<leader>ep", M.add_pipe, { desc = "[E]lixir Add [P]ipe" })
vim.keymap.set("n", "<leader>eP", M.remove_pipe, { desc = "[E]lixir Remove [P]ipe" })
return M
