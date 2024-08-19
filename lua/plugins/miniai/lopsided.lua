local M = {}
local L = {}
local Side = {}
Side.__index = Side
function Side.new()
  local self = setmetatable({}, Side)
  self.char = nil
  self.count = 0
  self.done = false
  return self
end
function Side:backspace()
  if self.count > 0 then
    self.count = self.count - 1
    self.done = false
    if self.count == 0 then
      self.char = nil
    end
    return true
  else
    return false
  end
end
function Side:input(char)
  if self.done then
    return false
  elseif self.char == nil then
    self.char = char
    self.count = 1
    return true
  elseif self.char == char then
    self.count = self.count + 1
    return true
  elseif char == "<CR>" and self.done == false then
    self.done = true
    return true
  else
    self.done = true
    return false
  end
end

local State = {}
State.__index = State
function State.new(ai)
  local self = setmetatable({}, State)
  self.left = Side.new()
  self.right = Side.new()
  self.ai = ai
  return self
end
local ns = vim.api.nvim_create_namespace("miniai.lopsided")
function State:highlight()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  if not (self.left.done and self.right.done) then
    local bounds = self:bounds()
    if bounds then
      print(".")
      vim.api.nvim_buf_set_extmark(
        0,
        ns,
        bounds.from.line - 1,
        bounds.from.col - 1,
        { end_col = bounds.to.col, end_line = bounds.to.line - 1, hl_group = "MiniaiLopsided", strict = false }
      )
    end
  end
end
function State:bounds()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local start = self.left.char and utils.find_back(self.left.char, cursor, self.left.count) or cursor
  local stop = self.right.char and utils.find_fwd(self.right.char, cursor, self.right.count) or cursor
  if start == nil or stop == nil then
    return nil
  end
  if self.ai == "i" then
    return { from = { line = start[1], col = start[2] + 1 }, to = { line = stop[1], col = stop[2] - 1 }, vis_mode = "v" }
  else
    return { from = { line = start[1], col = start[2] }, to = { line = stop[1], col = stop[2] }, vis_mode = "v" }
  end
end

L.get_char = function()
  local ok, char = pcall(vim.fn.getcharstr)
  for _, i in ipairs({ "<CR>", "<Esc>", "<BS>" }) do
    if char == vim.api.nvim_replace_termcodes(i, true, false, true) then
      return i
    end
  end

  return char
end
L.backspace = function(state)
  return state.right:backspace() or state.left:backspace()
end
L.loop = function(state)
  state:highlight()
  vim.schedule(function()
    state:highlight()
  end)
  if state.left.done and state.right.done then
    return state:bounds()
  end
  local char = L.get_char()
  if char == "<Esc>" then
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    return nil
  elseif char == "<BS>" then
    L.backspace(state)
    return L.loop(state)
  else
    local _ = state.left:input(char) or state.right:input(char)
    return L.loop(state)
  end
end
M.call = function(ai)
  vim.api.nvim_set_hl(0, "MiniaiLopsided", { underline = true, bold = true, bg = "#c34043", sp = "#c34043", default = true, force = true })
  return L.loop(State.new(ai))
end
return M
