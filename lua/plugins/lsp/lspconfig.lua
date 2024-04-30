local M = {}

M.signs = {
  Error = "ﮊ",
  Warn = "󱅧",
  Hint = "﮸",
  Info = "",
}

function M.setup()
  local lsp = vim.lsp

  local config = require("lspconfig")
  local mason = require("plugins.lsp.mason")

  local lua = require("plugins.lsp.servers.lua")
  local rust = require("plugins.lsp.servers.rust")
  local ocaml = require("plugins.lsp.servers.ocaml")
  local rescript = require("plugins.lsp.servers.rescript")
  local typescript = require("plugins.lsp.servers.typescript")
  local json = require("plugins.lsp.servers.json")
  local yaml = require("plugins.lsp.servers.yaml")
  -- local elixir = require("plugins.lsp.servers.elixir")
  -- local emmet = require("plugins.lsp.server.emmet")
  vim.diagnostic.config({
    signs = true,
    severity_sort = true,
  })

  local lspconfig = require("lspconfig")
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
  ocaml.setup(config)
  rescript.setup(config)
  -- typescript.setup(config)
  json.setup(config)
  yaml.setup(config)
  -- elixir.setup(config)
  -- elixir.setup({
  --   nextls = nextls_opts,
  --   credo = { enable = false },
  --   elixirls = { enable = true },
  -- })
  -- emmet.setup()

  config.emmet_language_server.setup({
    filetypes = {
      "css",
      "eruby",
      "html",
      "htmldjango",
      "javascriptreact",
      "less",
      "pug",
      "sass",
      "scss",
      "typescriptreact",
      "elixir",
      "heex",
    },
  })
  config.bashls.setup({})
  config.cssls.setup({})
  config.dockerls.setup({})
  config.docker_compose_language_service.setup({})
  config.html.setup({})
  config.marksman.setup({})
  config.nil_ls.setup({})
  config.ocamllsp.setup({})
  config.reason_ls.setup({})
  config.sqlls.setup({})
  -- config.elixirls.setup({})
  -- config.tailwindcss.setup({})
end

return M
