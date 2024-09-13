local M = {}

function M.inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end
function M.animate(ms, fun, after_fun, step)
  step = step or math.floor(ms / 10)
  local timer = vim.uv.new_timer()
  if timer then
    local progress = 0
    timer:start(step, step, function()
      progress = progress + step
      if progress >= ms then
        timer:stop()
        vim.schedule(function()
          after_fun()
        end)
      else
        local eased = M.inOutQuad(progress, 0, 1, ms)
        vim.schedule(function()
          fun(eased)
        end)
      end
    end)
  end
end

local ns = vim.api.nvim_create_namespace("mrs_doubtfire.animate")
local hls = {
  "MD_Trail_1",
  "MD_Trail_2",
  "MD_Trail_3",
  "MD_Trail_4",
  "MD_Trail_5",
}
function M.move_cursor(start_pos, end_pos, time)
  local adiff = end_pos[1] - start_pos[1]
  local bdiff = end_pos[2] - start_pos[2]
  local dir = start_pos[2] < end_pos[2] and "right" or "left"
  M.animate(time or 100, function(pct)
    local pos = { math.floor(start_pos[1] + (adiff * pct)), math.floor(start_pos[2] + (bdiff * pct)) }
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    local hl_opts = {}
    local j = 1
    if dir == "right" then
      for i = pos[2], math.max(start_pos[2], pos[2] - 4), -1 do
        table.insert(hl_opts, { hl_group = hls[j], pos = { pos[1], i }, end_col = i + 1 })
        j = j + 1
      end
    else
      for i = pos[2], math.min(pos[2] + 4, start_pos[2]) do
        table.insert(hl_opts, { hl_group = hls[j], pos = { pos[1], i + 1 }, end_col = i + 2 })
        j = j + 1
      end
    end
    for _, i in ipairs(hl_opts) do
      vim.api.nvim_buf_set_extmark(
        0,
        ns,
        i.pos[1] - 1,
        i.pos[2],
        { hl_group = i.hl_group, end_col = i.end_col, strict = false }
      )
    end
    vim.api.nvim_win_set_cursor(0, hl_opts[1].pos)
  end, function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    vim.api.nvim_win_set_cursor(0, end_pos)
  end)
end

return M
