local M = {}
M.__index = M

local detect = require("scratch_pad.detect")

function M._new_from_id(id)
  local buf = {
    lines = {},
    filetype = "elixir",
    id = id,
    created_at = os.time(),
    finished_detection = false,
  }
  setmetatable(buf, M)
  vim.schedule(function()
    buf:open_buffer()
  end)
  return buf
end

function M:open_buffer()
  self.bufnr = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(self.bufnr, "scratch_" .. self.id)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)

  vim.api.nvim_set_option_value("filetype", self.filetype, { buf = self.bufnr })
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = self.bufnr })
  vim.api.nvim_buf_attach(self.bufnr, false, {
    on_lines = function()
      self:updated()
    end,
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = self.bufnr,
    callback = function(args)
      local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
      local resp = M.format_elixir(lines, function(resp)
        if resp[1] then
          vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, resp[2])
        else
          require("notify")(resp[2])
        end

        vim.api.nvim_set_option_value("modified", false, { buf = self.bufnr })
      end)
    end,
  })
  return self.bufnr
end
M.reverse = function(t)
  local ret = {}
  local len = #t
  for i = len, 1, -1 do
    ret[len - i + 1] = t[i]
  end
  return ret
end
M.append = function(t1, t2)
  if #t1 == 0 then
    return t2
  end
  if #t2 == 0 then
    return t1
  end
  if #t1 > 0 and #t2 > 0 then
    t1[#t1] = t1[#t1] .. t2[1]
    for i = 2, #t2 do
      if t2[i] then
        table.insert(t1, t2[i])
      end
    end
  end
  return t1
end
function M.format_elixir(lines, fun)
  local stdout = {}
  local job = vim.fn.jobstart(
    "elixir /Users/peterrichards/Desktop/formatme.exs " .. vim.fn.shellescape(table.concat(lines, "\n")),
    {
      on_exit = function(id, data, event)
        fun({ data == 0, stdout })
      end,
      on_stdout = function(id, data, event)
        stdout = M.append(stdout, data)
      end,
    }
  )
  return { false, "Unknown error" }
  -- local handle = P()
  -- io.popen("elixir /Users/peterrichards/Desktop/formatme.exs " .. vim.fn.shellescape(table.concat(lines, "\n")))
  -- if handle then
  --   local result = handle:read("*all")
  --   local rc = { handle:close() }
  --   P(rc)
  --   local x = rc[3] == 1 and false or rc[1]
  --   return { x, result }
  -- else
  --   return { false, "Unknown error" }
  -- end
end

function M._new_from_params(params)
  return M.decode(params)
end

function M.new(id)
  if type(id) == "number" or type(id) == "string" then
    return M._new_from_id(id)
  elseif type(id) == "table" then
    return M._new_from_params(id)
  end
end
local pick_top_score = function(scores)
  local top = scores[1]
  local rem = top[2]
  local count = 0
  table.remove(scores, 1)
  for _, v in ipairs(scores) do
    if rem > 0 then
      count = count + 1
      rem = rem - v[2]
    end
  end

  if count > (#scores / 2) then
    return top[1]
  end
end

function M:updated()
  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  self.lines = lines
  -- if self.scores ~= "done" and #lines > 1 then
  --   self.scores = self.scores or {}
  --   if self.scores[#lines - 1] == nil then
  --     local scores = detect.detect(self.bufnr)
  --     self.scores[#lines - 1] = pick_top_score(scores)
  --     self.scores.last_line_count = #lines
  --     if self.scores[#lines - 1] then
  --       vim.bo.filetype = self.scores[#lines - 1]
  --       self.filetype = self.scores[#lines - 1]
  --     end
  --   end
  --   if M.finished_detection(self.scores) then
  --     self.scores = "done"
  --   end
  -- end
  require("scratch_pad").state:updated()
end

function M.finished_detection(scores)
  if #scores < 3 then
    return false
  end
  local t = {}
  for k, v in pairs(scores) do
    t[v] = t[v] or 0
    t[v] = t[v] + 1
  end
  local t2 = {}
  for k, v in pairs(t) do
    table.insert(t2, { k, v })
  end
  table.sort(t2, function(a, b)
    return a[2] > b[2]
  end)
  return t2[1][2] >= 3
end

function M.decode(params)
  local buf = {
    lines = params.lines or {},
    filetype = params.filetype,
    id = params.id,
    created_at = params.created_at,
    bufnr = nil,
    finished_detection = params.finished_detection or false,
  }
  setmetatable(buf, M)
  return buf
end

function M:encode()
  return {
    lines = self.lines,
    filetype = self.filetype,
    id = self.id,
    finished_detection = self.finished_detection,
    created_at = self.created_at,
  }
end

return M
