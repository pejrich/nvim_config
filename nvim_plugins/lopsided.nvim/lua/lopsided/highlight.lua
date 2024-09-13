local M = {}
---@alias position [integer, integer] A 1-indexed position in the buffer
---@class selection
---@field first_pos position
---@field last_pos position

---@class selections
---@field left selection|nil
---@field right selection|nil

-- Gets the position of the cursor, 1-indexed.
---@return position @The position of the cursor.
---@nodiscard
M.get_curpos = function()
  local curpos = vim.api.nvim_win_get_cursor(0)
  return { curpos[1], curpos[2] + 1 }
end

-- Sets the position of the cursor, 1-indexed.
---@param pos position|nil The given position.
M.set_curpos = function(pos)
  if not pos then
    return
  end
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
end

-- Move the cursor to a location in the buffer, depending on the `move_cursor` setting.
---@param pos { first_pos: position, old_pos: position } Various positions in the buffer.
M.restore_curpos = function(pos)
  -- TODO: Add a `last_pos` field for if `move_cursor` is set to "end"
  -- if config.get_opts().move_cursor == "begin" then
  --   M.set_curpos(pos.first_pos)
  -- elseif not config.get_opts().move_cursor then
  M.set_curpos(pos.old_pos)
  -- end
end

-- Highlights a given selection.
---@param selection selection|nil The selection to be highlighted.
M.highlight_selection = function(selection)
  if not selection then
    return
  end
  M.clear_highlights()
  local namespace = vim.api.nvim_create_namespace("LopsidedHighlight")

  vim.highlight.range(
    0,
    namespace,
    "LopsidedHighlight",
    { selection.first_pos[1] - 1, selection.first_pos[2] - 1 },
    { selection.last_pos[1] - 1, selection.last_pos[2] - 1 },
    { inclusive = true, id = 999, priority = 999 }
  )
  -- Force the screen to highlight the text immediately
  vim.cmd.redraw()
end

-- Clears all nvim-surround highlights for the buffer.
M.clear_highlights = function()
  local namespace = vim.api.nvim_create_namespace("LopsidedHighlight")
  vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
  -- Force the screen to clear the highlight immediately
  vim.cmd.redraw()
end
return M
