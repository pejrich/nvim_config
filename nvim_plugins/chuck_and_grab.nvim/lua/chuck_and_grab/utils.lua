local M = {}

M.getchar = function()
  vim.cmd("redraw")
  local ok, ret = pcall(vim.fn.getchar)
  return ok and ret or nil
end
local keep_cursor_pos_ns = vim.api.nvim_create_namespace("dontmoveme")
function M.keep_cursor_pos(fn)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ext = vim.api.nvim_buf_set_extmark(0, keep_cursor_pos_ns, cursor[1] - 1, cursor[2], {})
  fn()
  local extcursor = vim.api.nvim_buf_get_extmark_by_id(0, keep_cursor_pos_ns, ext, {})
  vim.api.nvim_win_set_cursor(0, { extcursor[1] + 1, extcursor[2] })
  vim.api.nvim_buf_clear_namespace(0, keep_cursor_pos_ns, 0, -1)
end

-- M.cut_lines_at = function(index, count)
--   count = count or 1
--   local lines = vim.api.nvim_buf_get_lines(0, index - 1, index + count - 1, false)
--   vim.api.nvim_buf_set_lines(0, index - 1, index + count - 1, false, {})
--   return lines
-- end
-- M.add_lines_at = function(index, lines, count)
--   count = count or 0
--   vim.api.nvim_buf_set_lines(0, index - 1, index - 1 + count, false, lines)
-- end
---Gets the lines between a range.
---@param sRow number Start row (Zero-indexed)
---@param eRow number End row (end-exclusive)
---@return table
M.get_target = function(sRow, eRow)
  return vim.api.nvim_buf_get_lines(0, sRow, eRow, true)
end

---Move the block of code selected
-- M.move_range = function(block, sRow, eRow)
--   vim.api.nvim_buf_set_lines(0, sRow, eRow, true, block)
-- end

---Escapes visual-line mode and re-selects the block according to the new position.
---@param dir number Movement direction. One of -1, 1.
---@param vSRow number Start row of Visual area.
---@param vERow number End row of Visual area.
M.reselect_block = function(dir, vSRow, vERow)
  vim.api.nvim_exec2(":normal! \\e\\e", { output = false })
  vim.api.nvim_exec2(
    ":normal! " .. (dir > 0 and vSRow + 2 or vSRow) .. "ggV" .. (vERow + dir) .. "gg",
    { output = false }
  )
end
M.current_line_idx = function()
  return vim.fn.line(".")
end
M.get_text = function(pos1, pos2)
  return vim.api.nvim_buf_get_text(0, pos1[1] - 1, pos1[2], pos2[1] - 1, pos2[2], {})
end
M.curpos = function()
  return vim.api.nvim_win_get_cursor(0)
end
M.rel_move_line_by = function(rel, dir)
  M.move_line_by(M.current_line_idx() + rel, dir)
end
-- M.move_current_line = function(dir)
--   M.move_line(M.current_line_idx(), dir)
-- end
M.move_current_line_by = function(dir)
  M.move_line_by(M.current_line_idx(), dir)
end
M.copy_line_by = function(pos, dir)
  local lines = vim.api.nvim_buf_get_lines(0, pos - 1, pos, false)
  vim.api.nvim_buf_set_lines(0, pos - 1 + dir, pos - 1 + dir, false, lines)
end

M.copy_lines_by = function(start, stop, dir)
  local lines = vim.api.nvim_buf_get_lines(0, start, stop, false)
  vim.api.nvim_buf_set_lines(0, start + dir, start + dir, false, lines)
end
M.move_lines_by = function(start, stop, dir, copy)
  if copy then
    M.copy_lines_by(start, stop, dir)
    return
  end
  if dir == 0 then
    return
  end
  if dir > 0 then
    local lines = vim.api.nvim_buf_get_lines(0, start, start + (stop - start) + dir, false)
    for i = 1, stop - start do
      table.insert(lines, lines[1])
      table.remove(lines, 1)
    end
    vim.api.nvim_buf_set_lines(0, start, start + (stop - start) + dir, false, lines)
  else
    local lines = vim.api.nvim_buf_get_lines(0, start + dir, stop, false)
    for i = 1, stop - start do
      table.insert(lines, 1, lines[#lines])
      table.remove(lines, #lines)
    end
    vim.api.nvim_buf_set_lines(0, start + dir, stop, false, lines)
  end
end

M.move_line_by = function(pos, dir, copy)
  if copy then
    M.copy_line_by(pos, dir)
    return
  end
  if dir == 0 then
    return
  else
    if dir > 0 then
      local lines = vim.api.nvim_buf_get_lines(0, pos - 1, pos + dir, false)
      table.insert(lines, lines[1])
      table.remove(lines, 1)
      vim.api.nvim_buf_set_lines(0, pos - 1, pos + dir, false, lines)
    else
      local lines = vim.api.nvim_buf_get_lines(0, pos + dir - 1, pos, false)
      table.insert(lines, 1, lines[#lines])
      table.remove(lines, #lines)
      vim.api.nvim_buf_set_lines(0, pos + dir - 1, pos, false, lines)
    end
  end
end

-- M.move_line = function(pos, dir)
--   if dir == 0 then
--     return
--   end
--   if dir > 0 then
--     M.swap_line(pos, pos + 1)
--     M.move_line(pos + 1, dir - 1)
--   else
--     M.swap_line(pos, pos - 1)
--     M.move_line(pos - 1, dir + 1)
--   end
-- end
---Set the lines for a given range.
-- M.swap_line = function(source, target)
--   local current_line = vim.fn.line(".")
--   -- local col = vim.api.nvim_win_get_cursor(0)[2]
--   local lSource = {}
--   local lTarget = {}
--
--   if source == nil and target == nil then
--     error("Invalid lines")
--   elseif source == nil and target ~= nil then
--     source = current_line
--   elseif source ~= nil and target == nil then
--     error("Invalid target line")
--   end
--
--   lSource = vim.api.nvim_buf_get_lines(0, source - 1, source, true)
--   lTarget = vim.api.nvim_buf_get_lines(0, target - 1, target, true)
--
--   vim.api.nvim_buf_set_lines(0, source - 1, source, true, lTarget)
--   vim.api.nvim_buf_set_lines(0, target - 1, target, true, lSource)
--
--   -- Set cursor position
--   -- vim.api.nvim_win_set_cursor(0, { target, col })
-- end

---Counts the indent of the line
---@param line number
---@return number
local function countIndent(line)
  return vim.fn.indent(line) / vim.fn.shiftwidth()
end

---Calculates the indentation to applied for a target line.
---@param target number
---@param dir number
---@return number
M.calc_indent = function(target, dir)
  local tCount = countIndent(target)
  local nCount = countIndent(target + dir)

  if tCount < nCount then
    return nCount
  else
    return tCount
  end
end

---Indents a block of code an amount of times between sLine and eLine.
---@param amount number Amount of times to indent.
---@param sLine number Start of indenting zone.
---@param eLine number End of indenting zone.
M.indent_block = function(amount, sLine, eLine)
  local cRow = sLine or vim.api.nvim_win_get_cursor(0)[1]
  local eRow = eLine or cRow

  local cIndent = countIndent(cRow)
  local diff = amount - cIndent

  if diff < 0 then
    vim.cmd("silent! " .. cRow .. "," .. eRow .. string.rep("<", math.abs(diff)))
  elseif diff > 0 then
    vim.cmd("silent! " .. cRow .. "," .. eRow .. string.rep(">", diff))
  end
end

---
---@param amount number
---@param sLine number
---@param eLine? number
M.indent = function(amount, sLine, eLine)
  local cRow = sLine or vim.api.nvim_win_get_cursor(0)[1]
  local eRow = eLine or cRow

  local cIndent = countIndent(cRow)
  local diff = amount - cIndent

  vim.cmd("silent! normal! ==")
  local newInd = countIndent(cRow)

  vim.cmd("silent! " .. cRow .. "," .. eRow .. string.rep("<", newInd))
  vim.cmd("silent! " .. cRow .. "," .. eRow .. string.rep(">", cIndent))

  if cIndent ~= newInd and diff ~= 0 then
    if cIndent < newInd then
      vim.cmd("silent! " .. cRow .. "," .. eRow .. string.rep(">", newInd - cIndent))
    else
      vim.cmd("silent! " .. cRow .. "," .. eRow .. string.rep("<", cIndent - newInd))
    end
  elseif diff > 0 then
    vim.cmd("silent! " .. cRow .. "," .. eRow .. string.rep(">", diff))
  end
end

---Calculates the start or end line of a fold.
---@param line number Line number to calculate the fold.
---@param dir number Direction of the movement. One of -1, 1.
---@return number
M.calc_fold = function(line, dir)
  local offset = -1

  if dir > 0 then
    offset = vim.fn.foldclosedend(line + dir)
  else
    offset = vim.fn.foldclosed(line + dir)
  end

  return offset
end

M.cursor_col = function()
  return vim.api.nvim_win_get_cursor(0)[2] + 1
end

--- Calculates the start and end column of the word
--by the lenght of the copy word
---@param word table
M.calc_cols = function(word)
  vim.cmd([[:normal! viWy]])

  -- Save position of word
  word.sCol = M.cursor_col()
  word.eCol = vim.fn.getreg("0"):len() + word.sCol - 1
end

---Moves the cursor forwards or backwards
--by the direction and then calls calc_cols
---@param word table
---@param dir number
M.calc_word_cols = function(word, dir)
  if dir > 0 then
    vim.cmd([[:normal! W]])
  else
    vim.cmd([[:normal! B]])
  end

  M.calc_cols(word)
end

local function rebuild_line(words, line, dir)
  local begL = ""
  local sep = ""
  local endL = ""
  local new_line = ""

  if dir > 0 then
    begL = line:sub(0, words.cursor.sCol - 1)
    sep = line:sub(words.cursor.eCol + 1, words.other.sCol - 1)
    endL = line:sub(words.other.eCol + 1, #line)
    new_line = begL .. words.other.value .. sep .. words.cursor.value .. endL
  elseif dir < 0 then
    begL = line:sub(0, words.other.sCol - 1)
    sep = line:sub(words.other.eCol + 1, words.cursor.sCol - 1)
    endL = line:sub(words.cursor.eCol + 1, #line)
    new_line = begL .. words.cursor.value .. sep .. words.other.value .. endL
  end

  return new_line
end

--- Replaces the cursor line, with the words passed swaped.
---@param words table
---@param line string
---@param dir number
M.swap_words = function(words, line, dir)
  local new_line = rebuild_line(words, line, dir)
  vim.api.nvim_set_current_line(new_line)
end

return M
