require("neovide")
require("settings")
require("globals")
require("plugins")
require("theme")
require("keymaps")
require("commands")

if vim.g.neovide then
  vim.defer_fn(function()
    vim.cmd("NeovideFocus")
  end, 25)
end
