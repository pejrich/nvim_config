local M = {
  'nvimdev/lspsaga.nvim',
  config = function()
    require('lspsaga').setup {
      code_action = '',
      actionfix = '',
    }
  end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- optional
    'nvim-tree/nvim-web-devicons', -- optional
  },
}
return { M }
