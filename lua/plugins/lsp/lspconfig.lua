local M = {}

M.signs = {
  Error = "",
  Warn = "",
  Hint = "",
  Info = "",
}

function M.setup()
  local lsp = vim.lsp

  local config = require("lspconfig")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local mason = require("plugins.lsp.mason")
  local lua = require("plugins.lsp.servers.lua")
  local rust = require("plugins.lsp.servers.rust")
  local typescript = require("plugins.lsp.servers.typescript")
  -- local json = require("plugins.lsp.servers.json")
  local yaml = require("plugins.lsp.servers.yaml")
  local elixir = require("plugins.lsp.servers.elixir")
  -- local tailwind = require("plugins.lsp.servers.tailwind")
  vim.diagnostic.config({
    signs = true,
    severity_sort = true,
  })

  local configs = require("lspconfig.configs")
  -- local elixir = require("elixir")

  -- local nextls_opts = {
  --   enable = true,
  --   spitfire = true,
  --   init_options = {
  --     experimental = {
  --       completions = {
  --         enable = true,
  --       },
  --     },
  --     ["mixEnv"] = "dev",
  --   },
  --   format = true,
  --   settings = {
  --     ["mixEnv"] = "dev",
  --   },
  -- }
  --
  -- -- if not configs.nextls then
  -- configs.nextls = {
  --   default_config = {
  --     cmd = { "nextls", "--stdio" },
  --     root_dir = lspconfig.util.root_pattern(".git"),
  --     filetypes = { "elixir", "eelixir", "heex" },
  --     settings = {
  --       ["mixEnv"] = "dev",
  --     },
  --   },
  -- }
  -- end
  -- lspconfig.nextls.setup({
  --   enable = true,
  --   format = true,
  --   init_options = {
  --     ["mixEnv"] = "dev",
  --   },
  --   settings = {
  --     ["mixEnv"] = "dev",
  --   },
  -- })
  --
  -- if not configs.elixirls then
  --   configs.elixirls = {
  --     default_config = {
  --       cmd = { "elixir-ls", "--stdio" },
  --       root_dir = lspconfig.util.root_pattern(".git"),
  --       filetypes = { "elixir", "eelixir", "heex" },
  --       cmd_env = {
  --         mixEnv = "dev",
  --       },
  --       init_options = {
  --         mixEnv = "dev",
  --       },
  --       settings = {
  --         mixEnv = "dev",
  --         elixirLS = {
  --           mixEnv = "dev",
  --         },
  --       },
  --     },
  --   }
  -- end
  -- lspconfig.elixirls.setup({
  --   enable = true,
  --   format = true,
  --   init_options = {
  --     ["mixEnv"] = "dev",
  --   },
  -- })
  for type, icon in pairs(M.signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "rounded" })

  mason.setup()

  lua.setup(config)
  rust.setup()
  typescript.setup(config)
  -- json.setup(config)
  yaml.setup(config)
  elixir.setup(config)
  -- tailwind.setup(config)

  config.emmet_language_server.setup({
    capabilities = capabilities,
    filetypes = {
      "html",
      "elixir",
      "heex",
    },
  })
  config.cssls.setup({})
  config.html.setup({})
end

return M
