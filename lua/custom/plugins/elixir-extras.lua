local M = {
  {
    'emmanueltouzery/elixir-extras.nvim',
    config = function()
      require('elixir-extras').setup_multiple_clause_gutter()
    end,
  },
}
return M
