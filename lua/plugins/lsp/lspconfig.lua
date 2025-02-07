local M = {}

M.signs = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.HINT] = "",
  [vim.diagnostic.severity.INFO] = "",
}

function M.setup()
  local lsp = vim.lsp

  local config = require("lspconfig")
  local capabilities =
    vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), require("cmp_nvim_lsp").default_capabilities())
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
  local sign_table = { text = {}, linehl = {}, numhl = {} }
  for type, icon in pairs(M.signs) do
    local hl = "DiagnosticSign" .. type
    sign_table.text[type] = icon
    sign_table.linehl[type] = hl
    sign_table.numhl[type] = hl
  end
  vim.diagnostic.config({
    signs = sign_table,
  })

  lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "rounded" })

  mason.setup()

  lua.setup(config, capabilities)
  rust.setup(config, capabilities)
  typescript.setup(config, capabilities)
  -- json.setup(config)
  yaml.setup(config, capabilities)
  elixir.setup(config, capabilities)
  -- tailwind.setup(config)

  config.emmet_language_server.setup({
    capabilities = capabilities,
    filetypes = {
      "html",
      "elixir",
      "heex",
    },
  })
  config.cssls.setup({
    settings = {
      css = {
        validate = false,
        lint = {
          unknownAtRules = "ignore",
        },
      },
    },
    default_config = {

      settings = {
        css = {
          validate = false,
          lint = {
            unknownAtRules = "ignore",
            unknown_at_rules = "ignore",
          },
        },
      },
    },
  })
  config.html.setup({})
end

return M
