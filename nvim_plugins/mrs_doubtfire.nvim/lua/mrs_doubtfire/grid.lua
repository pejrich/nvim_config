local util_ui = require("mrs_doubtfire.utils.ui")
local keys = require("mrs_doubtfire.utils.keys")
local enum = require("mrs_doubtfire.utils.enum")
local M = {}
local ns = vim.api.nvim_create_namespace("mrs_doubtfire.grid")
local grid_ns = vim.api.nvim_create_namespace("mrs_doubtfire.grid.line")
-- local horiz_ns = vim.api.nvim_create_namespace("mrs_doubtfire.grid.horiz_line")

function M.cleanup()
  -- vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(0, grid_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(0, grid_ns, 0, -1)
end
local current_lines = {}

function M.draw_vert_line(col)
  M.clear_vert_line()
  local bounds = MD.c.ui.buffer_window_bounds()
  local adj_col = col - bounds.minX
  local rows = util_ui.row_range()
  current_lines = {}
  for i = rows[1] - 1, rows[2] do
    local char = vim.api.nvim_exec("echo strcharpart(strpart(getline(" .. i + 1 .. "), " .. col .. "), 0, 1)", true)
    if char:len() == 0 then
      char = " "
    end
    local id = vim.api.nvim_buf_set_extmark(0, grid_ns, i, 0, {
      hl_group = "IncSearch",
      virt_text = { { char, "IncSearch" } },
      virt_text_win_col = adj_col,
      hl_mode = "combine",
    })
    table.insert(current_lines, id)
  end
end
function M.draw_horiz_line(line)
  M.clear_horiz_line()
  local char = vim.api.nvim_exec("echo getline(" .. line + 1 .. ")", true)
  local id = vim.api.nvim_buf_set_extmark(0, grid_ns, line, 0, {
    hl_group = "IncSearch",
    hl_eol = true,
    virt_text = { { char, "IncSearch" } },
    end_col = 0,
    end_line = line + 1,
    -- hl_mode = "combine",
  })
  current_lines = { id }
end
function M.clear_horiz_line()
  vim.api.nvim_buf_clear_namespace(0, grid_ns, 0, -1)
  for _, id in ipairs(current_lines) do
    vim.api.nvim_buf_del_extmark(0, grid_ns, id)
  end
end

function M.flash_horiz_line(line, ms)
  local t = vim.loop.new_timer()
  M.draw_horiz_line(line)
  t:start(ms or 150, 0, function()
    vim.schedule(function()
      M.clear_horiz_line()
    end)
  end)
end
function M.flash_vert_line(col, ms)
  local t = vim.loop.new_timer()
  M.draw_vert_line(col)
  t:start(ms or 150, 0, function()
    vim.schedule(function()
      M.clear_vert_line()
    end)
  end)
end

function M.clear_vert_line()
  vim.api.nvim_buf_clear_namespace(0, grid_ns, 0, -1)

  for _, id in ipairs(current_lines) do
    vim.api.nvim_buf_del_extmark(0, grid_ns, id)
  end
end
-- A..L
function M.distribute_A_L(min, max)
  return M.distribute_vert(min, max)
end
function M.distribute_vert(min, max)
  local gap = ((max - min) / #keys.VERT) / 2
  local ret = {}
  local count = min
  for i = 1, #keys.VERT do
    ret[keys.VERT[i]] = math.floor(count)
    count = count + gap + gap
  end
  return ret
end
-- A..L
function M.get_vert_indexes(bounds)
  return M.distribute_vert(bounds.minY, bounds.maxY)
end

function M.distribute_Q_P(min, max)
  return M.distribute_horiz(min, max)
end
-- Left to Right Q-P
function M.distribute_horiz(min, max)
  local gap = math.floor(((max - min) / #keys.HORIZ))
  local ret = {}
  local count = min + 1
  local flex = math.ceil(#keys.HORIZ / 2) + 3
  for i = 1, #keys.HORIZ do
    ret[keys.HORIZ[i]] = count
    local new_count = count + gap - flex
    count = new_count > count and new_count or count + 1
    flex = flex - 1
  end
  return ret
end
-- Q..P
function M.get_horiz_indexes(bounds)
  return M.distribute_horiz(bounds.minX, bounds.maxX)
end

-- Border Guides

function M.draw_border_guides(chars)
  local bounds = util_ui.buffer_window_bounds()
  M.draw_horiz_border_guide(bounds, chars)
  M.draw_vert_border_guide(bounds)
end
function M.remove_border_guides()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end
function M.draw_vert_border_guide(bounds)
  for k, v in pairs(M.get_vert_indexes(bounds)) do
    pcall(vim.api.nvim_buf_set_extmark, 0, ns, v, -1, {
      sign_text = k,
      sign_hl_group = "Define",
      -- number_hl_group = "Define",
      -- line_hl_group = "Define",
    })
  end
end
-- Q..P
function M.draw_horiz_border_guide(bounds, chars)
  local style = "overlay"
  chars = (chars or "") .. string.rep("_", 2 - (chars or ""):len())
  local text = "   "
  local prev = 0
  local vals = M.distribute_horiz(0, bounds.width)
  for _, i in ipairs(keys.HORIZ) do
    text = text .. string.rep(" ", vals[i] - prev - 2) .. i
    prev = vals[i] - 1
  end

  MD.c.prompt.set_grid(text)
  -- local gap = math.floor((bounds.width / #keys.HORIZ) / 2)
  -- local text = table.concat(enum.map(keys.HORIZ, function(key)
  --   return string.rep(" ", gap - 1) .. key .. string.rep(" ", gap)
  -- end))
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.api.nvim_buf_set_extmark(0, ns, (bounds.botline or 1) - 1, 0, {
    sign_text = chars,
    -- virt_text = { { text, "Define" } },
    -- virt_text_pos = style,
    sign_hl_group = "MsgArea",
    strict = false,
    priority = 999,
  })
end

---@return CharInfo?
function M.parse_char(char)
  local charinfo = keys.lookup_key(char)
  if charinfo then
    local bounds = util_ui.buffer_window_bounds()
    if charinfo.dir == "vert" then
      local x = M.get_vert_indexes(bounds)
      if x[charinfo.char] then
        charinfo.line = x[charinfo.char]
        M.flash_horiz_line(x[charinfo.char])
      end
    else
      local x = M.get_horiz_indexes(bounds)

      if x[charinfo.char] then
        charinfo.col = x[charinfo.char]
        M.flash_vert_line(x[charinfo.char])
      end
    end
  end
  return charinfo
end
return M
