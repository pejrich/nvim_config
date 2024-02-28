local M = {
  {
    "RRethy/nvim-treesitter-endwise",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "typescript", "rust", "json" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        endwise = {
          enable = true,
        },
      })
    end
  }
}

return M
