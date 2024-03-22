local M = {
  {
    'gbprod/yanky.nvim',
    config = function()
      local utils = require 'yanky.utils'
      local mapping = require 'yanky.telescope.mapping'
      require('yanky').setup {
        ring = {
          history_length = 100,
          storage = 'shada',
          sync_with_numbered_registers = true,
          cancel_event = 'update',
          ignore_registers = { '_' },
          update_register_on_cycle = false,
        },
        system_clipboard = {
          sync_with_ring = true,
        },
        highlight = {
          on_yank = false,
          timer = 250,
          picker = {
            telescope = {
              mappings = {
                default = mapping.put 'p',
                i = {
                  ['<c-g>'] = mapping.put 'p',
                  ['<c-k>'] = mapping.put 'P',
                  ['<c-x>'] = mapping.delete(),
                  ['<c-r>'] = mapping.set_register(utils.get_default_register()),
                },
                n = {
                  p = mapping.put 'p',
                  P = mapping.put 'P',
                  d = mapping.delete(),
                  r = mapping.set_register(utils.get_default_register()),
                },
              },
            },
          },
        },
      }
      vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
      vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)')
      vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')

      vim.keymap.set('n', '<c-p>', '<Plug>(YankyPreviousEntry)')
      vim.keymap.set('n', '<c-n>', '<Plug>(YankyNextEntry)')
      vim.keymap.set('n', ']p', '<Plug>(YankyPutIndentAfterLinewise)')
      vim.keymap.set('n', '[p', '<Plug>(YankyPutIndentBeforeLinewise)')
      vim.keymap.set('n', ']P', '<Plug>(YankyPutIndentAfterLinewise)')
      vim.keymap.set('n', '[P', '<Plug>(YankyPutIndentBeforeLinewise)')

      vim.keymap.set('n', '>p', '<Plug>(YankyPutIndentAfterShiftRight)')
      vim.keymap.set('n', '<p', '<Plug>(YankyPutIndentAfterShiftLeft)')
      vim.keymap.set('n', '>P', '<Plug>(YankyPutIndentBeforeShiftRight)')
      vim.keymap.set('n', '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)')

      vim.keymap.set('n', '=p', '<Plug>(YankyPutAfterFilter)')
      vim.keymap.set('n', '=P', '<Plug>(YankyPutBeforeFilter)')
    end,
  },
}
return M
