local M = {}
local m = {}

function M.setup()
  local mason = require("mason")
  local config = require("mason-lspconfig")

  mason.setup({})

  config.setup({
    -- NOTE: rust is handled by the `rust-tools`
    ensure_installed = {
      "bashls",
      "cssls",
      "html",
      "lua_ls",
      "emmet_language_server",
      "ts_ls",
      "yamlls",
    },
  })
end

function M.keymaps() end

function M.ensure_hidden()
  if m.is_active() then
    m.close()
    return true
  else
    return false
  end
end

-- Private

function m.is_active()
  return vim.bo.filetype == "mason"
end

function m.close()
  local keys = require("editor.keys")
  keys.send("q", { mode = "x" })
end

return M
