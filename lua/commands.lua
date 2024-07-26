local function kill_elixirls()
  vim.cmd([[!ps waxl | grep "beam.smp"]])
  local x = vim.api.nvim_exec([[!ps waxl | grep "beam.smp"]], true)
  x = vim.split(x, "\n")
  local reload = false
  for _, i in ipairs(x) do
    if i:match("language_server") then
      local pid = i:match("^ *[0-9]* *([0-9]*)")
      vim.api.nvim_exec("!kill -9 " .. pid, true)
      print("Killed ElixirLS")
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
  {
    { "LspDetach" },
    {
      callback = function(args)
        local file = args.file
        if string.sub(file, #file - 1, #file) == "ex" then
          if kill_elixirls() then
            vim.cmd("LspStart elixirls")
          end
        end
      end,
    },
  },
  {
    { "VimLeavePre" },
    {
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
