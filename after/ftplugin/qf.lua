vim.keymap.set("n", "<S-CR>", function()
  local line = vim.fn.line(".")
  vim.cmd(utils.esc_codes("ccl\"))
  vim.cmd(utils.esc_codes(":cc " .. line .. "\"))
end, { buffer = 0 })
