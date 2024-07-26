local M = {}

function M.setup(config, capabilities)
  vim.g.rustaceanvim = {
    -- Plugin configuration
    tools = {},
    -- LSP configuration
    server = {
      capabilities = capabilities,
      on_attach = function(_client, _bufnr)
        -- TODO: Add keymaps here
      end,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    },
    -- DAP configuration
    dap = {},
  }
end

return M
