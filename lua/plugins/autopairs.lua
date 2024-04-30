local M = {}

function M.setup()
  local plugin = require("nvim-autopairs")

  plugin.setup({
    check_ts = true,
    enable_check_bracket_line = true,
  })
end

return M
