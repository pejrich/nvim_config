local M = {}

function M.setup()
  local plugin = require("nvim-autopairs")

  plugin.setup({
    check_ts = true,
    enable_check_bracket_line = false,
    ignored_next_char = "[%w%.]",
    fast_wrap = {},
  })
end

return M
