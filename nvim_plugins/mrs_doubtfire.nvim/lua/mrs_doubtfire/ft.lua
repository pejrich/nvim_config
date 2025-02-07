local M = {}

function M.op_cb(arg)
  P(arg)
end
function M.trigger()
  vim.go.operatorfunc = "v:lua.require'mrs_doubtfire.ft'.op_cb"
  return "g@"
end

vim.keymap.set({ "n" }, "f", M.trigger, { expr = true, remap = false })

return M
