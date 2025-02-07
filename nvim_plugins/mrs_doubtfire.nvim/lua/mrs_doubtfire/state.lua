local M = {}
M.__index = M
local SLIDE_MS = 250

---@class MatchPOS
---@field x integer
---@field y integer
---@field match_id integer

---div div a div div b div div c div div d div div e div div f

---@class Bounds
---@field minX integer
---@field maxX integer
---@field minY integer
---@field maxY integer

---@class Line
---@field index integer
---@field text string
---@field matches Match[]

---@class State
---@field target_keys string[]
---@field keypresses string[]
---@field gridpress {vert: CharInfo?, horiz: CharInfo?}
---@field preferred_match_id integer?
---@field bounds Bounds
---@field lines Line[]
---@field is_jump_mode boolean

---@class SubstringRange
---@field start integer
---@field stop integer
---@field text string

---@class Match: SubstringRange
---@field id integer
---@field line_number integer
---@field index_in_line integer
---@field next_match integer
---@field prev_match integer
---@field next_line_match integer
---@field prev_line_match integer
---@field cursor_position [integer, integer]
---@field score integer
---@field label string
---@field forward_matches SubstringRange[]
---@field backward_matches SubstringRange[]

function M.new()
  local self = setmetatable({}, M)
  self.target_keys = {}
  self.keypresses = {}
  self.gridpress = { vert = nil, horiz = nil }
  self.bounds = MD.c.ui.visible_bounds()
  self.is_jump_mode = false
  self:reset_lines()
  return self
end

function M:reset_lines()
  self.lines = MD.c.buffer.get_visible_lines()
  self:update()
end

function M:update_lines()
  local bounds = MD.c.ui.buffer_window_bounds()
  local new_lines = {}
  local fwd = self:forward_keys()
  local bwd = self:backward_keys()
  local pat = MD.c.search.create_pattern(self.target_keys, fwd, bwd)
  local first_match = nil
  local first_line = nil
  local prev_line = {}
  local prev_match = nil
  for i, line in ipairs(self.lines) do
    local matches = MD.c.search.process_line(line, pat, bounds)
    if #matches > 0 then
      local pl = {}
      for m, n in ipairs(matches) do
        n.index_in_line = m
        if prev_match then
          n.prev_match = prev_match.id
          prev_match.next_match = n.id
        end
        local prev_line_match = prev_line[m] or prev_line[#prev_line]
        if prev_line_match then
          n.prev_line_match = prev_line_match.id
          prev_line_match.next_line_match = prev_line_match.next_line_match or n.id
        end
        prev_match = n
        table.insert(pl, n)
        first_match = first_match or n
      end
      first_line = first_line or pl
      prev_line = pl
      line["matches"] = matches
      table.insert(new_lines, line)
    end
  end
  if prev_match and first_match then
    first_match.prev_match = prev_match.id
    prev_match.next_match = first_match.id
  end
  if first_line then
    for i2, j in ipairs(first_line) do
      j.prev_line_match = (prev_line[i2] or prev_line[#prev_line]).id
    end
    for i2, j in ipairs(prev_line) do
      j.next_line_match = (first_line[i2] or first_line[#first_line]).id
    end
  end
  self.lines = new_lines
  MD.c.labeler.label_matches(self:all_matches())
end

-- function M.display(str)
--   local row = MD.c.ui.top_row() + 5
--   local bounds = MD.c.ui.window_bounds()
--   local width = MD.c.ui.line_width(row)
--   local gap = (bounds.width - width)
--   local space = string.rep(" ", (gap - str:len()) / 2)
--   local display = space .. str .. space
--   vim.api.nvim_buf_set_extmark(0, MD.const.ns, row - 1, width - 1, {
--     virt_text = { { display, "Define" } },
--   })
-- end

function M.clear_hl()
  for _, m in ipairs(vim.api.nvim_buf_get_extmarks(0, MD.const.ns, 0, -1, {})) do
    vim.api.nvim_buf_del_extmark(0, MD.const.ns, m[1])
  end
  vim.api.nvim_buf_clear_namespace(0, MD.const.ns, 0, -1)
end

---@return Match?
function M:single_match()
  if self:is_single_match() then
    return self.lines[1].matches[1]
  end
end
function M:is_single_match()
  return #self.lines == 1 and #self.lines[1].matches == 1
end

---@param id integer
---@return Match?
function M:match_by_id(id)
  return MD.c.enum.find(self:all_matches(), function(m)
    return m.id == id
  end)
end

function M:line_inc_preferred_match()
  local match = self:preferred_match()
  if match and match.next_line_match then
    self.preferred_match_id = match.next_line_match
  else
    self.preferred_match_id = self.lines[1].matches[1].id
  end
  self:update_ui()
end

function M:line_dec_preferred_match()
  local match = self:preferred_match()
  if match and match.prev_line_match then
    self.preferred_match_id = match.prev_line_match
  else
    local matches = self.lines[#self.lines].matches
    self.preferred_match_id = matches[#matches].id
  end

  self:update_ui()
end
function M:inc_preferred_match()
  if #self.target_keys == 0 then
    MD.set_jump_mode()
    MD.c.jumper.jump_to_prev(1)
    return
  end
  local match = self:preferred_match()
  if match and match.next_match then
    self.preferred_match_id = match.next_match
  else
    local matches = self:all_matches()
    local next_matches = MD.c.enum.drop_while(matches, function(m)
      return m.id ~= self.preferred_match_id
    end)
    if #next_matches > 1 then
      self.preferred_match_id = next_matches[2].id
    else
      self.preferred_match_id = matches[1].id
    end
  end
  self:update_ui()
end

function M:dec_preferred_match()
  if #self.target_keys == 0 then
    MD.set_jump_mode()
    MD.c.jumper.jump_to_prev(-1)
    return
  end
  local match = self:preferred_match()
  if match and match.prev_match then
    self.preferred_match_id = match.prev_match
  else
    local matches = self:all_matches()
    local next_matches = MD.c.enum.take_while(matches, function(m)
      return m.id ~= self.preferred_match_id
    end)
    if #next_matches > 1 then
      self.preferred_match_id = next_matches[#next_matches].id
    else
      self.preferred_match_id = matches[#matches].id
    end
  end
  self:update_ui()
end

---@return Match?
function M:preferred_match()
  if self.preferred_match_id then
    return self:match_by_id(self.preferred_match_id)
  end
  local match = MD.c.enum.reduce(self:all_matches(), { score = 9999999, match = nil }, function(match, acc)
    if match.score < acc.score then
      return { score = match.score, match = match }
    elseif match.score == acc.score then
      return { score = match.score, match = nil }
    else
      return acc
    end
  end)
  if match.match then
  end
  return match.match
end

function M:highlight()
  M.clear_hl()
  local sm = self:single_match()
  if sm then
    MD.c.hl.hl_area(sm.line_number, sm.start, sm.stop + 1, "MD_FinalTargetMatch")
    -- vim.api.nvim_buf_add_highlight(0, MD.const.ns, "FinalTargetMatch", line.index, match.start, match.stop + 1)
  end
  local preferred_match = self:preferred_match()
  local matches = self:all_matches()
  MD.c.labeler.label_matches(matches)
  for _, match in ipairs(matches) do
    MD.c.hl.hl_area(match.line_number, match.start, match.stop + 1, "MD_GhostTargetMatch")
    -- for _, line in ipairs(self.lines) do
    --   for _, match in ipairs(line.matches) do
    if match.label then
      if preferred_match and match.id == preferred_match.id then
        MD.c.hl.label_area(match.line_number, match.start, match.stop + 1, "MD_PreferredTargetMatch", match.label)
      else
        MD.c.hl.label_area(match.line_number, match.start, match.stop + 1, "MD_LabeledMatch", match.label)
      end
    else
      if preferred_match and match.id == preferred_match.id then
        MD.c.hl.hl_area(match.line_number, match.start, match.stop + 1, "MD_PreferredTargetMatch")
      else
        MD.c.hl.hl_area(match.line_number, match.start, match.stop + 1, "MD_TargetMatch")
      end
    end

    for _, adtl in ipairs(match.backward_matches) do
      MD.c.hl.hl_area(match.line_number, adtl.start, adtl.stop + 1, "MD_BackwardMatches")
    end
    for _, adtl in ipairs(match.forward_matches) do
      MD.c.hl.hl_area(match.line_number, adtl.start, adtl.stop + 1, "MD_ForwardMatches")
    end
    -- end
  end
end

function M:all_matches()
  local ret = {}
  for _, i in ipairs(self.lines) do
    for _, j in ipairs(i.matches) do
      table.insert(ret, j)
    end
  end
  return ret
end

---@return MatchPOS[]
function M:all_match_positions()
  local ret = {}
  for _, i in ipairs(self.lines) do
    for _, j in ipairs(i.matches) do
      table.insert(ret, { x = j.start + ((j.stop - j.start) / 2), y = i.index, match_id = j.id })
    end
  end
  return ret
end

function M:recalc_matches()
  if #self.target_keys == 2 then
    self:update_lines()
    MD.c.locator.reduce(self)
  end
end

function M:update_ui()
  if #self.target_keys == 2 then
    self:highlight()
  end
  MD.c.grid.draw_border_guides()
  MD.c.prompt.set(table.concat(self.target_keys))
end

function M:update()
  self:recalc_matches()
  self:update_ui()
end

---@param key string
function M:insert_forward(key)
  if #self.target_keys < 2 then
    table.insert(self.target_keys, key)
  else
    table.insert(self.keypresses, key:lower())
  end
  self:update()
end

---@param key string
function M:insert_backward(key)
  table.insert(self.keypresses, key:upper())
  self:update()
end

---@return string[]
function M:forward_keys()
  local ret = {}
  for _, key in ipairs(self.keypresses) do
    if key == key:lower() then
      table.insert(ret, key)
    end
  end
  return ret
end

---@return string[]
function M:backward_keys()
  local ret = {}
  for _, key in ipairs(self.keypresses) do
    if key == key:upper() then
      table.insert(ret, key)
    end
  end
  return ret
end

---@return boolean
function M:confirm()
  if #self.target_keys == 0 then
    MD.c.jumper.jump_to_current()
    return true
  end
  local sm = self:single_match()
  if sm then
    MD.c.prompt.hide()
    MD.c.jumper.new_jump(sm.cursor_position)
    return true
  end
  local pm = self:preferred_match()
  if pm then
    MD.c.prompt.hide()
    MD.c.jumper.new_jump(pm.cursor_position)
    return true
  end
  return false
end

function M:backspace()
  if #self.keypresses == 0 then
    if #self.target_keys == 0 then
      return
    else
      table.remove(self.target_keys, #self.target_keys)
    end
  else
    table.remove(self.keypresses, #self.keypresses)
  end
  self:reset_lines()
end

---@param key string
---@return boolean?
function M:ctrl_key_pressed(key)
  local charinfo = MD.c.grid.parse_char(key)
  if charinfo then
    if #self.target_keys ~= 0 then
      if self.gridpress[charinfo.dir] ~= nil then
        self.gridpress[charinfo.dir] = charinfo
        self:reset_lines()
      else
        self.gridpress[charinfo.dir] = charinfo
        self:update()
      end
    else
      local cursor = vim.api.nvim_win_get_cursor(0)
      if charinfo.line then
        local line = vim.api.nvim_buf_get_lines(0, charinfo.line, charinfo.line + 1, false)
        MD.c.animate.move_cursor(cursor, { charinfo.line + 1, math.min(line[1]:len(), cursor[2]) }, SLIDE_MS)
      end
      if charinfo.col then
        local line = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)
        local diff = charinfo.col - line[1]:len()
        MD.c.animate.move_cursor(cursor, { cursor[1], math.min(charinfo.col - 1, line[1]:len()) }, SLIDE_MS)
        -- if diff > 0 and (diff / charinfo.col) > 0.1 then
        --   local jumped = false
        --   local max_index = nil
        --   local max_length = 0
        --   -- for i = 1, 5 do
        --   --   local l1 = vim.api.nvim_buf_get_lines(0, cursor[1] - 1 + i, cursor[1] + i, false)[1]
        --   --   local l2 = vim.api.nvim_buf_get_lines(0, cursor[1] - 1 - i, cursor[1] - i, false)[1]
        --   --   if l1 == nil or l2 == nil then
        --   --     break
        --   --   end
        --   --   if l1:len() > max_length then
        --   --     max_index = cursor[1] + i - 1
        --   --     max_length = l1:len()
        --   --   end
        --   --   if l2:len() > max_length then
        --   --     max_index = cursor[1] - i - 1
        --   --     max_length = l2:len()
        --   --   end
        --   --   local diff1 = charinfo.col - l1:len()
        --   --   local diff2 = charinfo.col - l2:len()
        --   --   if diff1 < 0 or (diff1 > 0 and (diff1 / charinfo.col) < 0.1) then
        --   --     jumped = true
        --   --     MD.c.animate.move_cursor(cursor, { cursor[1] + i - 1, math.min(charinfo.col - 1, l1:len()) }, SLIDE_MS)
        --   --     break
        --   --   end
        --   --   if diff2 < 0 or (diff2 > 0 and (diff2 / charinfo.col) < 0.1) then
        --   --     jumped = true
        --   --     MD.c.animate.move_cursor(cursor, { cursor[1] - i - 1, math.min(charinfo.col - 1, l2:len()) }, SLIDE_MS)
        --   --     break
        --   --   end
        --   -- end
        --   if not jumped then
        --     P(max_index)
        --     P(charinfo)
        --     P(max_length)
        --     MD.c.animate.move_cursor(cursor, { max_index, math.min(charinfo.col - 1, max_length) }, SLIDE_MS)
        --   end
        -- else
        -- end
      end
      return true
    end
  end
end

function M.cleanup()
  MD.c.prompt.hide()
  M.clear_hl()
end

return M
