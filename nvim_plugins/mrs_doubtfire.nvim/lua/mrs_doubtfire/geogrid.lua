local M = {}
local ns = vim.api.nvim_create_namespace("mrs_doubtfire.backdrop")
-- Quadrant Numbering
--
--                 |
--         2       |     1
--                 |
--    -------------|----------
--     32  |  31   |
--    -----3-----  |    4
--     33  |  34   |
--
M.state = nil
function M.init()
  M.state = { current = "", bounds = MD.c.ui.visible_bounds() }
  M.draw_state()
end
function M.update(quad)
  P(M.state.bounds)
  if quad == 1 then
    M.state.bounds.minX = M.state.bounds.midX
    M.state.bounds.maxY = M.state.bounds.midY
  elseif quad == 2 then
    M.state.bounds.maxX = M.state.bounds.midX
    M.state.bounds.maxY = M.state.bounds.midY
  elseif quad == 3 then
    M.state.bounds.maxX = M.state.bounds.midX
    M.state.bounds.minY = M.state.bounds.midY
  elseif quad == 4 then
    M.state.bounds.minX = M.state.bounds.midX
    M.state.bounds.minY = M.state.bounds.midY
  end
  M.state.current = M.state.current .. quad
  M.draw_state()
end

function M.draw_state()
  local state = M.state
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.api.nvim_buf_set_extmark(0, ns, state.bounds.midY, state.bounds.midX - 12, {
    virt_text = { { "-", "Substitute" }, { "          ", "" }, { "--+--", "Substitute" }, { "          ", "" }, { "-", "Substitute" } },
    virt_text_pos = "overlay",
    virt_text_win_col = state.bounds.midX - 13,
    strict = false,
  })

  vim.api.nvim_buf_set_extmark(0, ns, state.bounds.midY - 1, state.bounds.midX, {
    virt_text = { { "|", "Substitute" } },
    virt_text_pos = "overlay",
    virt_text_win_col = state.bounds.midX,
    strict = false,
  })

  vim.api.nvim_buf_set_extmark(0, ns, state.bounds.midY + 1, state.bounds.midX, {
    virt_text = { { "|", "Substitute" } },
    virt_text_pos = "overlay",
    virt_text_win_col = state.bounds.midX,
    strict = false,
  })

  vim.api.nvim_buf_set_extmark(0, ns, state.bounds.minY, state.bounds.maxX, {
    virt_text = { { "||", "Substitute" } },
    virt_text_pos = "overlay",
    virt_text_win_col = state.bounds.maxX,
    strict = false,
  })

  vim.api.nvim_buf_set_extmark(0, ns, state.bounds.maxY, state.bounds.minX, {
    virt_text = { { "||", "Substitute" } },
    virt_text_pos = "overlay",
    virt_text_win_col = state.bounds.minX,
    strict = false,
  })
end

-- vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
-- M.init()
-- M.update(2)
-- M.update(1)
-- M.update(1)
-- M.update(1)
return M
