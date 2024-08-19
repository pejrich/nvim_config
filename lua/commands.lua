_G.NOOP = function(arg)
  print("NOOP called")
  P(arg)
  P(vim.api.nvim_buf_get_mark(0, "<"))
  P(vim.api.nvim_buf_get_mark(0, ">"))

  P(vim.api.nvim_buf_get_mark(0, "["))
  P(vim.api.nvim_buf_get_mark(0, "]"))
end

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
      end,
    },
  },
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

for _, x in ipairs(autocmds) do
  for _, event in ipairs(x[1]) do
    vim.api.nvim_create_autocmd(event, x[2])
  end
end
