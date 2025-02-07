local M = {}

function M.setup()
  local plugin = require("nvim-autopairs")

  plugin.setup({
    check_ts = true,
    enable_check_bracket_line = true,
    ignored_next_char = "[%w%.]",
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      end_key = "$",
      before_key = "h",
      after_key = "l",
      cursor_pos_before = true,
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      -- manual_position = true,
      highlight = "Search",
      highlight_grey = "Comment",
    },
  })
end

return M
