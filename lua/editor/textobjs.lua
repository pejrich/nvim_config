local M = {}
M.tobjs = {}
_G.TOBJ = function(arg)
  print("NOOP called")
  P(arg)
  -- P(vim.api.nvim_buf_get_mark(0, "<"))
  -- P(vim.api.nvim_buf_get_mark(0, ">"))

  local start = vim.api.nvim_buf_get_mark(0, "[")
  local stop = vim.api.nvim_buf_get_mark(0, "]")
  local obj = { type = arg, start = start, stop = stop }
  if M.tobjs[#M.tobjs] ~= obj then
    table.insert(M.tobjs, obj)
  end
end
--   vim.go.operatorfunc = "v:lua.NOOP"
--   vim.cmd.normal({ args = { "g@i)" }, bang = false })
--   local x = vim.api.nvim_replace_termcodes("vi)il<esc>", true, true, true)
--   vim.cmd.normal({ args = { x }, bang = false })
--   NOOP()
-- end)
-- vim.cmd.normal({ args = { "g@i)il" }, bang = true })

function M.textobj_callback(args)
  P("CALLED")
  P(args)
  P(vim.api.nvim_buf_get_mark(0, "<"))
end
function M.find_textobjs(textobj)
  vim.go.operatorfunc = "v:lua.TOBJ"
  keeping_pos(function()
    vim.cmd.normal({ args = { "g@" .. textobj }, bang = false })
  end)
  -- vim.api.nvim_feedkeys("g@" .. textobj, "n", true)
end

P(M.find_textobjs("i)"))

return M
