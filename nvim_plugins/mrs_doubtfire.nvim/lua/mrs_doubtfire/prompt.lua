---@class MrsDoubtfire.Prompt
---@field win window
---@field buf buffer
local M = {}

local Config = {
  relative = "editor",
  width = 1, -- when <=1 it's a percentage of the editor width
  height = 1,
  row = -1, -- when negative it's an offset from the bottom
  col = 0, -- when negative it's an offset from the right
  zindex = 1000,
}
local ns = vim.api.nvim_create_namespace("mrs_doubtfire_prompt")

function M.visible()
  return M.win and vim.api.nvim_win_is_valid(M.win) and M.buf and vim.api.nvim_buf_is_valid(M.buf)
end

function M.show()
  if M.visible() then
    return
  end

  M.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[M.buf].buftype = "nofile"
  vim.bo[M.buf].bufhidden = "wipe"
  vim.bo[M.buf].filetype = "mrs_doubtfire_prompt"

  local config = vim.deepcopy(Config)

  if config.width <= 1 then
    config.width = config.width * vim.go.columns
  end

  if config.row < 0 then
    config.row = vim.go.lines + config.row
  end

  if config.col < 0 then
    config.col = vim.go.columns + config.col
  end

  config = vim.tbl_extend("force", config, {
    style = "minimal",
    focusable = false,
    noautocmd = true,
  })

  M.win = vim.api.nvim_open_win(M.buf, false, config)
  vim.wo[M.win].winhighlight = "Normal:mrs_doubtfirePrompt"
end

function M.hide()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_delete(M.buf, { force = true })
    M.buf = nil
  end
end
local _grid = ""
local _pattern = "__"
function M.set_grid(grid)
  _grid = grid
  M.reset()
end
---@param pattern string
function M.set(pattern)
  _pattern = pattern
  if _pattern:len() < 2 then
    _pattern = _pattern .. string.rep("_", 2 - _pattern:len())
  end
  M.reset()
end
function M.reset()
  -- local pattern = _pattern .. _grid
  M.show()
  local text = vim.deepcopy({ { "🤨🔥", "MrsDoubtfirePromptIcon" } })
  text[#text + 1] = { _grid, "Define" }
  text[#text + 1] = { _pattern or "__" }

  local str = ""
  for _, item in ipairs(text) do
    str = str .. item[1]
  end
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, { str })
  vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
  local col = 0
  for _, item in ipairs(text) do
    local width = vim.fn.strlen(item[1])
    if item[2] then
      vim.api.nvim_buf_set_extmark(M.buf, ns, 0, col, {
        hl_group = item[2],
        end_col = col + width,
      })
    end
    col = col + width
  end
end

return M
