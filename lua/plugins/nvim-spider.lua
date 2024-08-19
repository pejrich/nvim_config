local M = {}

function M.keymaps()
  vim.keymap.set(
    { "n", "o", "x" },
    "w",
    "<cmd>lua require('spider').motion('w', {customPatterns = {overrideDefault = false, patterns = {'^', '$'}}})<CR>",
    { desc = "Spider-w" }
  )
  vim.keymap.set(
    { "n", "o", "x" },
    "e",
    "<cmd>lua require('spider').motion('e', {customPatterns = {overrideDefault = false, patterns = {'^', '$'}}})<CR>",
    { desc = "Spider-e" }
  )
  vim.keymap.set(
    { "n", "o", "x" },
    "b",
    "<cmd>lua require('spider').motion('b', {customPatterns = {overrideDefault = false, patterns = {'^', '$'}}})<CR>",
    { desc = "Spider-b" }
  )
end

return M
