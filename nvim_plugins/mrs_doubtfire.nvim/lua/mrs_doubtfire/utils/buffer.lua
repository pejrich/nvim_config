local M = {}

---@return Line[]
M.get_visible_lines = function()
  local bounds = MD.c.ui.visible_bounds()
  local lines = vim.api.nvim_buf_get_lines(0, bounds.minY, bounds.maxY, false)
  return MD.c.enum.zip(lines, MD.c.enum.range(bounds.minY, bounds.maxY), function(line, index)
    return { text = line, index = index }
  end)
end

return M
