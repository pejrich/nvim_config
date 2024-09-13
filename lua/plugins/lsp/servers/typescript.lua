local M = {}

function M.setup(config, capabilities)
  config.ts_ls.setup({
    capabilities = capabilities,
    on_attach = function(client)
      -- Formatting is handled by conform/prettier
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
    init_options = {
      preferences = {
        includeInlayParameterNameHints = false,
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = false,
        importModuleSpecifierPreference = "non-relative",
      },
    },
  })
end

return M
