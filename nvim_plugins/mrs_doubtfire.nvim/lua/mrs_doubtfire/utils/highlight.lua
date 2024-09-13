local const = require("mrs_doubtfire.constants")

local M = {}

function M.label_area(line, col_start, col_stop, hl, text)
  vim.api.nvim_buf_set_extmark(0, const.ns, line, col_start, {
    end_col = col_stop,
    hl_group = hl,
    virt_text = { { text, hl } },
    virt_text_pos = "overlay",
  })
end

function M.hl_area(line, col_start, col_stop, hl)
  vim.api.nvim_buf_set_extmark(0, const.ns, line, col_start, {
    end_col = col_stop,
    hl_group = hl,
  })
end

return M
