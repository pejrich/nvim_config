local M = {}

function M.setup()
  local ls = require("luasnip")
  ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
  })
  require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "~/.config/nvim/lua/snippets" } })
  vim.keymap.set({ "i" }, "<C-K>", function()
    ls.expand()
  end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-k>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-j>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-l>", function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end)
end

return M
