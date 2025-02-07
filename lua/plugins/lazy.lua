local M = {}
local m = {}

function M.keymaps() end

function M.ensure_hidden()
  if m.is_active() then
    m.close()
    return true
  else
    return false
  end
end

-- Private

function m.is_active()
  return vim.bo.filetype == "lazy"
end

function m.close()
  local keys = require("editor.keys")
  keys.send("q", { mode = "x" })
end

return M
