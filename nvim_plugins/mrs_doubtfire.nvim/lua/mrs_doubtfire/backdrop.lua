local M = {}
local ns = vim.api.nvim_create_namespace("mrs_doubtfire.backdrop")
function M.init()
  local win = vim.api.nvim_get_current_win()
  local info = vim.fn.getwininfo(win)[1]
  local buf = vim.api.nvim_win_get_buf(win)
  local from = { info.topline, 0 }
  local to = { info.botline + 1, 0 }
  -- we need to create a backdrop for each line because of the way
  -- extmarks priority rendering works
  for line = from[1], to[1] do
    vim.api.nvim_buf_set_extmark(buf, ns, line - 1, line == from[1] and from[2] or 0, {
      hl_group = "Comment",
      end_row = line == to[1] and line - 1 or line,
      hl_eol = line ~= to[1],
      end_col = line == to[1] and to[2] or from[2],
      strict = false,
    })
  end
end
function M.cleanup()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
