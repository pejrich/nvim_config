local M = {}

function M.setup()
  local ls = require("luasnip")
  local fmt = require("luasnip.extras.fmt").fmt
  ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
  })
  require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "~/.config/nvim/lua/snippets" } })
  local t, i, c, f = ls.text_node, ls.insert_node, ls.choice_node, ls.function_node
  local filename = function()
    return f(function(_args, snip)
      local str = vim.fn.substitute(vim.fn.expand("%"), ".*/*lib/", "/", "")
      str = vim.fn.substitute(str, ".*/*test/", "/", "")
      str = vim.fn.substitute(str, "\\([/]\\)\\(.\\)", ".\\U\\2", "g")
      str = vim.fn.substitute(str, "\\(_\\)\\(.\\)", "\\U\\2", "g")
      str = vim.fn.substitute(str, "\\.ex.*$", "", "")
      str = vim.fn.substitute(str, "^\\.", "", "")
      return str
    end)
  end
  local defmod = ls.s(
    "defmod",

    fmt(
      [[defmodule {} do
  {}
end]],
      { filename(), i(0) }
    )
  )
  ls.add_snippets("elixir", { defmod })
  vim.keymap.set({ "i" }, "<C-L>", function()
    ls.expand()
  end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-l>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-j>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-;>", function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end)
end

return M
