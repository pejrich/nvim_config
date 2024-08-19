local M = {}

function M.setup()
  vim.cmd("let g:beacon_size = 15")
  require("beacon").setup({
    enable = true,
    size = 15,
    fade = true,
    minimal_jump = 10,
    show_jumps = true,
    focus_gained = false,
    shrink = true,
    timeout = 500,
    ignore_buffers = {},
    ignore_filetypes = {},
  })
  vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    callback = function()
      vim.api.nvim_set_hl(0, "Beacon", { link = "BeaconDefault" })
    end,
  })
end

return M
