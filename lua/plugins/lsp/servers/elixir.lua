local M = {}

function M.setup(config)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  config.elixirls.setup({
    filetypes = { "elixir", "heex", "eex", "eelixir" },
    capabilities = capabilities,
    cmd = { "elixir-ls" },
    settings = { elixirLS = { dialyzerEnabled = false, fetchDeps = false, mixEnv = "dev" } },
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
  --       mix_env = "dev",
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
  --       mixEnv = "dev",
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
