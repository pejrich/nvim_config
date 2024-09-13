_G.NOOP = function(arg)
  print("NOOP called")
  P(arg)
  P(vim.api.nvim_buf_get_mark(0, "<"))
  P(vim.api.nvim_buf_get_mark(0, ">"))

  P(vim.api.nvim_buf_get_mark(0, "["))
  P(vim.api.nvim_buf_get_mark(0, "]"))
end
local ns = vim.api.nvim_create_namespace("PlusMinus")
local testing = function()
  keeping_pos(function()
    vim.go.operatorfunc = "v:lua.NOOP"
    vim.cmd.normal({ args = { "g@i)" }, bang = false })
    local x = vim.api.nvim_replace_termcodes("vi)il<esc>", true, true, true)
    vim.cmd.normal({ args = { x }, bang = false })
    NOOP()
  end)
  -- vim.cmd.normal({ args = { "g@i)il" }, bang = true })
end

local function kill_elixirls()
  -- vim.cmd([[!ps waxl | grep "beam.smp"]])
  local x = vim.api.nvim_exec2([[!ps waxl | grep "beam.smp"]], { output = true }).output
  x = vim.split(x, "\n")
  local reload = false
  for _, i in ipairs(x) do
    if i:match("language_server") or i:match("elixir-ls") then
      local pid = i:match("^ *[0-9]* *([0-9]*)")
      vim.api.nvim_exec2("!kill -9 " .. pid, { output = false })
      reload = true
    end
  end
  return reload
end
local autocmds = {

  {
    { "BufEnter" },
    {
      pattern = "*",
      callback = function()
        if vim.bo.ft == "help" then
          vim.api.nvim_command("wincmd L")
        end
        local apl = vim.b.AutoPairsList
        table.insert(apl, { "%{", "}", { key = "}", mapclose = 1, multiline = 1 } })
        vim.b.AutoPairsList = apl
        vim.b.AutoPairsShortcutToggle = ""
        vim.b.AutoPairsFlyMode = 1
        -- vim.cmd([[let b:AutoPairsList = b:AutoPairsList . ",['%{', '}', {'key': '}', 'mapclose': 1, 'multiline': 1}]"]])
      end,
    },
  },
  -- {
  --   { "CursorMoved" },
  --   {
  --     callback = function()
  --       vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  --       local pos = utils.cur_pos()
  --       local lines = tonumber(vim.api.nvim_exec2("echo line('$')", { output = true }).output)
  --       local bg = vim.api.nvim_exec2([[echo synIDattr(hlID("Normal"), "bg") ]], { output = true }).output
  --       local fg = vim.api.nvim_exec2([[echo synIDattr(synIDtrans(hlID("@label")), "fg") ]], { output = true }).output
  --       for i = 5, 25, 5 do
  --         local col = require("theme.colors").lighten(bg, 1.0 - (0.02 * (i / 5)), fg)
  --         vim.api.nvim_set_hl(0, "LinePM" .. i, { bg = col })
  --         if (pos[1] + i - 1) <= lines then
  --           vim.api.nvim_buf_set_extmark(0, ns, pos[1] + i - 1, 0, { line_hl_group = "LinePM" .. i, strict = false })
  --         end
  --         if (pos[1] - (i + 1)) >= 0 then
  --           vim.api.nvim_buf_set_extmark(0, ns, pos[1] - (i + 1), 0, { line_hl_group = "LinePM" .. i, strict = false })
  --         end
  --       end
  --     end,
  --   },
  -- },
  { { "BufEnter" }, { pattern = { "*.md", "*.mdx" }, command = "setlocal wrap" } },
  { { "Filetype" }, { pattern = "markdown", command = "lua vim.b.minitrailspace_disable = true" } },
  { { "TermOpen" }, { pattern = "*", command = "lua vim.b.minitrailspace_disable = true" } },
  { { "FocusGained" }, { pattern = "*", command = "checktime" } },
  {
    { "User" },
    {
      pattern = "AlphaReady",
      callback = require("plugins.alpha").on_open,
    },
  },
  {
    { "User" },
    {
      pattern = "AlphaClosed",
      callback = require("plugins.alpha").on_close,
    },
  },
  {
    { "User" },
    {
      pattern = "LazyVimStarted",
      once = true,
      callback = require("plugins.alpha").update_footer,
    },
  },
  {
    { "User" },
    {
      pattern = "ThemeApplied",
      callback = function()
        print("Theme applied")
      end,
    },
  },
  -- {
  --   { "LspDetach" },
  --   {
  --     pattern = { "*.ex", "*.exs" },
  --     callback = function(args)
  --       local file = args.file
  --       if kill_elixirls() then
  --         vim.api.nvim_command("LspStart elixirls")
  --       end
  --     end,
  --   },
  -- },
  {
    { "VimLeavePre" },
    {
      pattern = { "*.ex", "*.exs" },
      callback = function(_args)
        kill_elixirls()
      end,
    },
  },
}
vim.api.nvim_create_user_command("Msg", "NoiceHistory", {})
vim.api.nvim_create_user_command("Redir", function(ctx)
  local lines = vim.split(vim.api.nvim_exec(ctx.args, true), "\n", { plain = true })
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.opt_local.modified = false
end, { nargs = "+", complete = "command" })
for _, x in ipairs(autocmds) do
  for _, event in ipairs(x[1]) do
    vim.api.nvim_create_autocmd(event, x[2])
  end
end
