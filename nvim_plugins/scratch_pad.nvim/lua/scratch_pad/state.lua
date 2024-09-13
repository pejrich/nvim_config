local M = {}
local sb = require("scratch_pad.scratch_buf")

M.__index = M

function M.new(params)
  params = params or {}
  local bufs = {}
  for k, v in pairs(params.bufs or {}) do
    bufs[k] = sb.new(v)
  end
  local state = {
    count = params.count or 0,
    bufs = bufs,
  }
  setmetatable(state, M) -- make Account handle lookup
  return state
end

function M:open_buffer(id)
  if self.bufs[tostring(id)] then
    return self.bufs[tostring(id)]:open_buffer()
  else
    vim.api.nvim_err_writeln("Error opening buffer " .. id)
  end
end

function M:get_buffer(id)
  if self.bufs[tostring(id)] then
    return self.bufs[tostring(id)]
  end
end

function M:delete_buffer(id)
  self.bufs[tostring(id)] = nil
  self:save_state()
end
function M:new_buffer()
  local buf = sb.new(tostring(self.count))
  self.bufs[tostring(self.count)] = buf
  self.count = self.count + 1
  buf.state = self
  return buf
end

function M:encode()
  local bufs = {}
  for k, v in pairs(self.bufs) do
    bufs[k] = v:encode()
  end
  local data = {
    count = self.count,
    bufs = bufs,
  }
  return vim.json.encode(data)
end

M.filedir = function()
  return vim.fn.stdpath("data") .. "/scratch_pad"
end
M.state_file = function()
  return M.filedir() .. "/data.json"
end

function M:updated()
  self:save_state()
end

M.init_state = function()
  local state = M.new({})
  state:save_state()
  return state
end

function M.load_state()
  -- if vim.fn.filereadable(M.state_file()) == 1 then
  return M.new(vim.json.decode(table.concat(vim.fn.readfile(M.state_file()))))
  -- else
  -- return M.init_state()
end
-- end

function M:save_state()
  vim.fn.mkdir(M.filedir(), "p")
  local file, err = io.open(M.state_file(), "w")
  if file then
    file:close()
  else
    print("error:", err) -- not so hard?
  end
  vim.fn.writefile({ self:encode() }, M.state_file())
end

return M
