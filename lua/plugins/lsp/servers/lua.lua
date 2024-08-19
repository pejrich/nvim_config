local M = {}

function M.setup(config, capabilities)
  -- local neodev = require("neodev")

  -- neodev.setup({})

  config.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        format = {
          enable = true,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
end

return M
