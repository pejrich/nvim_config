local M = {}

local easing = require("chuck_and_grab.easing")
local utils = require("chuck_and_grab.utils")
local config = require("chuck_and_grab.config")

local hl_id = nil
function M.highlight(line_number, text, copy)
  local hl_group = copy and "Substitute" or "IncSearch"
  if line_number[1] < 0 then
    return
  end
  if not text then
    local line_text = vim.api.nvim_buf_get_lines(0, line_number[1], line_number[2], false)
    -- text = line_text[1]
  end
  M.unhighlight()
  local opts = {
    virt_text = { { table.concat(text, "\n"), hl_group } },
    virt_text_pos = "overlay",
    hl_group = hl_group,
    end_row = line_number[2],
    strict = false,
  }
  hl_id = vim.api.nvim_buf_set_extmark(0, config.ns, line_number[1], 0, opts)
end

function M.unhighlight()
  if hl_id then
    vim.api.nvim_buf_del_extmark(0, config.ns, hl_id)
  end
end

function M.sleep(time, func)
  local timer = vim.uv.new_timer()
  timer:start(
    math.ceil(time),
    0,
    vim.schedule_wrap(function()
      timer:stop()
      timer:close()
      func()
    end)
  )
end

function M.highlight_path(count, line, copy, func)
  if count == 0 then
    func()
  else
    if type(line) == "number" then
      line = { line - 1, line }
    end
    local text = vim.api.nvim_buf_get_lines(0, line[1], line[2], false)
    local move_after = count < 0
    local adjcount = count + (count < 0 and -1 or 1)
    local ms = math.min(math.floor(math.abs(count) * 10), 450) / config.multi_count
    local timing = easing.generate(math.abs(adjcount), ms)
    timing[1] = math.max(100 / config.multi_count, timing[1])
    timing[#timing] = math.max(100 / config.multi_count, timing[#timing])
    local cb = {
      function()
        if move_after then
          utils.move_lines_by(line[1], line[2], count, copy)
        end
      end,
    }
    local idx = math.max(1, math.abs(count) - 1)
    if cb[idx] == nil or not move_after then
      cb[idx] = function()
        if not move_after then
          utils.move_lines_by(line[1], line[2], count, copy)
        end
      end
    end
    M._highlight_path(line, adjcount, text, copy, timing, cb, function()
      func()
    end)
  end
end

function M._highlight_path(line, count, text, copy, timing, callbacks, func)
  if count == 0 then
    M.unhighlight()
    func()
    return
  end
  if callbacks[math.abs(count)] then
    callbacks[math.abs(count)]()
  end
  M.highlight(line, text, copy)
  local t = table.remove(timing, 1)
  M.sleep(t or 0, function()
    local sign = count > 0 and -1 or 1
    M._highlight_path({ line[1] - sign, line[2] - sign }, count + sign, text, copy, timing, callbacks, func)
  end)
end
return M
