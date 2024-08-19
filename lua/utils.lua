local M = {}
function M.unix_timestamp()
  return os.time(os.date("!*t"))
end
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
function M.cur_pos()
  return vim.api.nvim_win_get_cursor(0)
end

function M.cur_line()
  local pos = M.cur_pos()
  return vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
end

function M.cur_lines(before, after)
  before = before or 0
  after = after or 0
  local pos = M.cur_pos()
  return vim.api.nvim_buf_get_lines(0, pos[1] - 1 + before, pos[1] + after, false)
end

function M.replace_lines(before, after, text)
  local pos = M.cur_pos()
  vim.api.nvim_buf_set_lines(0, pos[1] - 1 + before, pos[1] + after, false, text)
end

function M.line_width(line)
  return #vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
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
