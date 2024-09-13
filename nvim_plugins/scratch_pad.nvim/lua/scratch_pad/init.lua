local M = {}
local sb = require("scratch_pad.scratch_buf")
local st = require("scratch_pad.state")
---@class ScratchBuf
---@field state State
---@field lines string[]
---@field filetype string?
---@field id integer
---@field created_at osdateparam
---@field bufnr integer?
---@field finished_detection boolean

---@class State
---@field count integer
---@field bufs ScratchBuf[]

M.state = nil
local buffer_to_string = function()
  local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return table.concat(content, "\n")
end
function M.new_buffer()
  local buf = M.state:new_buffer()
  -- vim.api.nvim_buf_attach(buf.bufnr, false, {
  --   on_lines = function()
  --     local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  --   end,
  -- })
  vim.schedule(function()
    vim.api.nvim_win_set_buf(0, buf.bufnr)
  end)
  -- for k, v in pairs(require("nvim-treesitter.parsers").get_parser_configs()) do
  -- end
end
function M.open_buffer(id)
  local bufnr = M.state:open_buffer(id)
  if bufnr then
    vim.schedule(function()
      vim.api.nvim_win_set_buf(0, bufnr)
    end)
  end
end
function M.open_picker()
  vim.schedule(function()
    require("scratch_pad.picker").open_picker()
  end)
end
-- P(M.get_languages())
-- P(detect.detect(M.get_languages()))
function M.setup()
  local km = vim.keymap.set
  km("n", "<A-n>", M.new_buffer, { noremap = true, silent = true, expr = true })
  km("n", "<leader><leader>s", M.open_picker, { noremap = true, silent = true, expr = true })
  M.state = st:load_state()
  -- P(M.state)
end
return M
