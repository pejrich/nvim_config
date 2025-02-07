local M = {}
local Pos = require("editor.pos")

function M.list_textobjs()
  local all = {}

  local vim_builtin = { "w", "W", "p", "s", "'", '"', "`", ")", "]", "}", "t", ">" }
  for _, i in ipairs(vim_builtin) do
    all[i] = true
  end
  local ts_tobj = vim.tbl_map(function(o)
    return "@" .. o
  end, require("nvim-treesitter.textobjects.shared").available_textobjects())

  for _, i in ipairs(ts_tobj) do
    all[i] = true
  end
  local miniai_builtin = { "(", ")", "[", "]", "{", "}", "<", ">", "'", '"', "`", "?", "a", "b", "f", "t", "q" }
  for _, i in ipairs(miniai_builtin) do
    all[i] = true
  end
  local miniai = require("mini.ai").config.custom_textobjects
  for k, v in pairs(miniai) do
    if v == nil or v == "" then
      all[k] = false
    else
      all[k] = true
    end
  end
  local final = {}
  for k, v in pairs(all) do
    if v then
      final[#final + 1] = k
    end
  end
  return final
end
-- P(M.list_textobjs())

M.tobjs = {}
_G.TOBJ = function(arg)
  -- P(vim.api.nvim_buf_get_mark(0, "<"))
  -- P(vim.api.nvim_buf_get_mark(0, ">"))

  local start = Pos.new(vim.api.nvim_buf_get_mark(0, "["))
  local stop = Pos.new(vim.api.nvim_buf_get_mark(0, "]"))
  local obj = { type = arg, start = start, stop = stop }
  if M.tobjs[#M.tobjs] ~= obj then
    table.insert(M.tobjs, obj)
  end
end
--   vim.go.operatorfunc = "v:lua.NOOP"
--   vim.cmd.normal({ args = { "g@i)" }, bang = false })
--   local x = vim.api.nvim_replace_termcodes("vi)il<esc>", true, true, true)
--   vim.cmd.normal({ args = { x }, bang = false })
--   NOOP()
-- end)
-- vim.cmd.normal({ args = { "g@i)il" }, bang = true })

_G.TOBJ_C = function(arg)
  local start = Pos.new(vim.api.nvim_buf_get_mark(0, "["))
  local stop = Pos.new(vim.api.nvim_buf_get_mark(0, "]"))
  local obj = { type = arg, start = start, stop = stop }
  local cb = M.tobj_c_callback
  if cb then
    cb(obj)
    M.tobj_c_callback = nil
  end
end
function M.tobj_callback(tobj, func)
  M.tobj_c_callback = func
  vim.go.operatorfunc = "v:lua.TOBJ_C"
  local pos = utils.cur_pos()
  vim.cmd.normal({ args = { "g@" .. tobj }, bang = false })
end
M.cur_pos = nil
local move_right = function()
  local pos = M.cur_pos
  local new_pos
  if pos[2] == utils.line_width(pos[1]) then
    new_pos = { pos[1] + 1, 0 }
  else
    new_pos = { pos[1], pos[2] + 1 }
  end
  vim.api.nvim_win_set_cursor(0, new_pos)
  M.cur_pos = new_pos
end
M.all_objs = {}

function M.hl_obj(obj)
  -- vim.api.nvim_buf_set_extmark(0, ns, obj.start[1], obj.start[2], {})
end
local loop_find = function(_, _) end
loop_find = function(tobj, cb)
  M.tobj_callback(tobj, function(val)
    if val then
      M.hl_obj(val)
      if M.all_objs[#M.all_objs] ~= val then
        table.insert(M.all_objs, val)
        vim.api.nvim_win_set_cursor(0, val.stop)
        M.cur_pos = val.stop
        move_right()
      else
        vim.api.nvim_win_set_cursor(0, { val.stop[1] + 1, 0 })
      end
      if vim.fn.line(".") == vim.fn.line("$") and vim.fn.charcol(".") == utils.line_width() then
        cb(M.all_objs)
      else
        loop_find(tobj, cb)
      end
    else
      cb(M.all_objs)
    end
  end)
end
local ns = vim.api.nvim_create_namespace("tobjs")
function M.find_all_textobjs(textobj)
  keeping_pos(function()
    local bounds = utils.visible_bounds()
    local win_width = bounds.maxX - bounds.minX
    local map = {}
    for i = bounds.minY, bounds.maxY - 1 do
      local width = utils.line_width(i)
      if width >= bounds.minX then
        table.insert(map, { start = Pos.new({ i, bounds.minX }), stop = Pos.new({ i, math.max(width, bounds.maxX) }) })
      end
    end
    local tobjs = {}
    local cur_pos = map[1].start
    local mark = nil
    cur_pos:go_to()
    for i, j in ipairs(map) do
      if mark == nil or j.start >= mark then
        cur_pos = j.start
        cur_pos:go_to()
        M.tobj_callback(textobj, function(val)
          mark = Pos.new(val.start)
          table.insert(tobjs, val)
        end)
      end
    end

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    for _, j in ipairs(tobjs) do
      vim.api.nvim_buf_set_extmark(
        0,
        ns,
        j.start.line - 1,
        j.start.col,
        { end_row = j.stop.row - 1, end_col = j.stop.col + 1, hl_group = "Substitute", strict = false }
      )
    end
  end)
  -- keeping_pos(function()
  --   vim.api.nvim_win_set_cursor(0, { 1, 0 })
  --   M.cur_pos = { 1, 0 }
  --   M.all_objs = {}
  --   loop_find(textobj, function(objs)
  --     P(objs)
  --   end)
  -- end)
end

vim.api.nvim_create_user_command("TxtObj", function(args)
  M.find_all_textobjs(args.args)
  P(args)
end, { nargs = "+" })
-- M.find_all_textobjs("i}")
return M
