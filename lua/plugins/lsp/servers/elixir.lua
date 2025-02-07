local M = {}

local restarts = 0
local last_restart = 0
local function kill_elixirls()
  -- vim.cmd([[!ps waxl | grep "beam.smp"]])
  local x = vim.api.nvim_exec2([[!ps waxl | grep "beam.smp"]], { output = true }).output
  x = vim.split(x, "\n")
  local reload = false
  for _, i in ipairs(x) do
    if i:match("language_server") or i:match("elixir-ls") then
      local pid = i:match("^ *[0-9]* *([0-9]*)")
      vim.notify("Killing Elixir-LS", vim.log.levels.DEBUG)
      vim.api.nvim_exec2("!kill -9 " .. pid, { output = false })
      if (utils.unix_timestamp() - last_restart) < 30 then
        if restarts < 3 then
          reload = true
          restarts = restarts + 1
        end
      else
        last_restart = utils.unix_timestamp()
        restarts = 1
        reload = true
      end
    end
  end
  return reload
end
function M.setup(config, capabilities)
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  config.elixirls.setup({
    server = {
      capabilities = capabilities,
    },
    default_config = {
      filetypes = { "elixir", "heex", "eex", "eelixir" },
      capabilities = capabilities,
      cmd = { "elixir-ls" },
      cmd_env = { MIX_ENV = "ls" },
    },
    filetypes = { "elixir", "heex", "eex", "eelixir" },
    capabilities = capabilities,
    cmd = { "elixir-ls" },
    cmd_env = { MIX_ENV = "ls" },
    settings = {
      mixEnv = "ls",
      elixirLS = { dialyzerEnabled = false, fetchDeps = true, mixEnv = "ls" },
    },
    on_exit = function(code, signal)
      vim.notify("elixir ls exit " .. code .. " signal: " .. signal)

      vim.schedule(function()
        if kill_elixirls() then
          vim.api.nvim_exec2("LspStart elixir-ls", { output = false })
        end
      end)
    end,
  })
  -- config.elixirls.setup({
  --   capabilities = capabilities,
  --   flags = {
  --     exit_timeout = 0,
  --   },
  --   elixirLS = {
  --     dialyzerEnabled = false,
  --     fetchDeps = false,
  --   },
  -- })
  --
  -- local elixir = require("elixir")
  -- local elixirls = require("elixir.elixirls")
  --
  -- elixir.setup({
  --   nextls = {
  --     enable = true, -- defaults to false
  --     -- port = 9000, -- connect via TCP with the given port. mutually exclusive with `cmd`. defaults to nil
  --     cmd = "nextls", -- path to the executable. mutually exclusive with `port`
  --     init_options = {
  --       mix_env = "ls",
  --       mix_target = "host",
  --       experimental = {
  --         completions = {
  --           enable = true, -- control if completions are enabled. defaults to false
  --         },
  --       },
  --     },
  --     on_attach = function(client, bufnr)
  --       -- custom keybinds
  --     end,
  --   },
  --   credo = {
  --     enable = true, -- defaults to true
  --     -- port = 9000, -- connect via TCP with the given port. mutually exclusive with `cmd`. defaults to nil
  --     -- cmd = "path/to/credo-language-server", -- path to the executable. mutually exclusive with `port`
  --     -- version = "0.1.0-rc.3", -- version of credo-language-server to install and use. defaults to the latest release
  --     on_attach = function(client, bufnr)
  --       -- custom keybinds
  --     end,
  --   },
  --   elixirls = {
  --     enable = true,
  --     -- specify a repository and branch
  --     -- repo = "mhanberg/elixir-ls", -- defaults to elixir-lsp/elixir-ls
  --     -- branch = "mh/all-workspace-symbols", -- defaults to nil, just checkouts out the default branch, mutually exclusive with the `tag` option
  --     -- tag = "v0.14.6", -- defaults to nil, mutually exclusive with the `branch` option
  --
  --     -- alternatively, point to an existing elixir-ls installation (optional)
  --     -- not currently supported by elixirls, but can be a table if you wish to pass other args `{"path/to/elixirls", "--foo"}`
  --     -- cmd = "/usr/local/bin/elixir-ls.sh",
  --
  --     -- default settings, use the `settings` function to override settings
  --     settings = elixirls.settings({
  --       mixEnv = "ls",
  --       dialyzerEnabled = true,
  --       -- fetchDeps = false,
  --       -- enableTestLenses = false,
  --       -- suggestSpecs = false,
  --     }),
  --     on_attach = function(client, bufnr)
  --       vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
  --       vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
  --       vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
  --     end,
  --   },
  -- })
end

return M
