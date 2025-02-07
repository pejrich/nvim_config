local M = {}

function M.setup()
  local d = require("ultimate-autopair.default")
  d.conf.internal_pairs = {
    { "[", "]", fly = true, dosuround = true, newline = true, space = true },
    { "(", ")", fly = true, dosuround = true, newline = true, space = true },
    { "{", "}", fly = true, dosuround = true, newline = true, space = true },
    {
      '"',
      '"',
      suround = true,
      cond = function(fn, o)
        return fn.get_ft() ~= "vim" or (not o.line:sub(1, o.col - 1):match("^%s*$") and o.line:sub(o.col - 1, o.col - 1) ~= "@")
      end,
      multiline = false,
    },
    {
      "'",
      "'",
      suround = true,
      cond = function(fn)
        return not fn.in_lisp() or fn.in_string()
      end,
      alpha = true,
      nft = { "tex", "rust" },
      multiline = false,
    },
    {
      "->",
      "end",

      cond = function()
        local line = vim.api.nvim_get_current_line()
        -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        -- string.sub(line, math.max(col - 1, 0), col)
        local res = line:find("fn ") and true or false
        return res
      end,
      multiline = false,
      newline = true,
      disable_end = true,
    },
    {
      "`",
      "`",
      cond = function(fn)
        return not fn.in_lisp() or fn.in_string()
      end,
      nft = { "tex" },
      multiline = false,
    },
    { "``", "''", ft = { "tex" } },
    { "```", "```", newline = true },
    { "<!--", "-->", space = true },
    { '"""', '"""', newline = true },
    { "'''", "'''", newline = true },
  }
  local ua = require("ultimate-autopair")
  ua.setup({
    undomap = "<M-U>",
    close = {
      enable = true,
      map = "<A-)>",
      cmap = "<A-)>",
      conf = {},
      multi = false,
      do_nothing_if_fail = true,
    },
    tabout = {
      enable = true,
      map = "<M-Tab>",
      cmap = "<M-Tab>",
    },
    -- { '"""', '"""', newline = true, ft = { "eelixir", "elixir", "heex", "lua" } },
    fastwarp = {
      multi = true,
      nocursormove = false,
      {},
      { faster = true, map = "<C-A-e>", cmap = "<C-A-e>" },
    },
  })
  local autotag = require("nvim-ts-autotag.internal")
  vim.keymap.set("i", ">", function()
    local res = require("ultimate-autopair.core").run_run(">")
    vim.api.nvim_feedkeys(res, "n", false)

    -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { res })
    -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { ">" })
    autotag.close_tag()
    -- vim.api.nvim_win_set_cursor(0, { row, col + 1 })

    -- ls.expand_auto()
  end, { remap = false, expr = false })
end

return M
