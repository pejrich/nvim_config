local M = {
  {
    'akinsho/bufferline.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      vim.opt.termguicolors = true
      require('bufferline').setup {
        options = {
          numbers = function(opts)
            return string.format('%s', opts.raise(opts.ordinal))
          end,
          indicator = {
            style = 'underline',
          },
        },
      }
    end,
  },
}
return M
