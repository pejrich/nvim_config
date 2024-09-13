local M = {}
M.augroup = vim.api.nvim_create_augroup("chuck_and_grab.nvim", { clear = true })
M.ns = vim.api.nvim_create_namespace("chuck_and_grab")
M.multi_count = 1
return M
