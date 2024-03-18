-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
-- vim.keymap.set('n', '<leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>', { desc = "Close buffer" })

return {
  {
    'rebelot/kanagawa.nvim',
    config = function()
      vim.opt.termguicolors = true

      vim.cmd 'colorscheme kanagawa'
    end,
  },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  {
    'projekt0n/github-nvim-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup {
        -- ...
      }

      -- vim.cmd 'colorscheme github_dark_dimmed'
    end,
  },
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('nordic').load()
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    'nvim-tree/nvim-web-devicons',
  },
}
