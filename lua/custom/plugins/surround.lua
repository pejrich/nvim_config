local M = {
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {
      keymaps = {
        normal = 'sa',
        normal_cur = 'ss',
        normal_line = 'sA',
        normal_cur_line = 'sAA',
        delete = 'sd',
        change = 'sc',
        change_line = 'sC',
      },
      move_cursor = false,
      aliases = {
        ['a'] = false,
      },
      surrounds = {
        ['p'] = {
          add = { 'IO.inspect(', ')' },
          find = 'IO%.inspect%b()',
          delete = '^(IO%.inspect%()().-(%))()$',
          change = {
            target = '^(IO%.inspect%()().-(%))()$',
          },
        },
        ['a'] = {
          add = { 'fn -> ', ' end' },
          find = 'fn .- -> .- end',
          delete = '^(fn .- -> )().-( end)()$',
          change = {
            target = '^(fn .- -> )().-( end)()$',
          },
        },
        ['A'] = {
          add = function()
            local config = require 'nvim-surround.config'
            local result = config.get_input 'Enter args: '
            if result then
              return { { 'fn ' .. result .. ' -> ' }, { ' end' } }
            end
          end,
          find = 'fn .- -> .- end',
          delete = '^(fn .- -> )().-( end)()$',
          change = {
            target = '^(fn .- -> )().-( end)()$',
          },
        },
      },
    },
  },
}
return M
-- local M = {
--   {
--     'kylechui/nvim-surround',
--     version = '*', -- Use for stability; omit to use `main` branch for the latest features
--     event = 'VeryLazy',
--     config = function()
--       require('nvim-surround').setup {
--         surrounds = {
--           ['['] = {
--             add = { '[', ']' },
--             find = function()
--               return M.get_selection { motion = 'a[' }
--             end,
--             delete = '^(. ?)().-( ?.)()$',
--           },
--         },
--         -- Configuration here, or leave empty to use defaults
--       }
--     end,
--   },
-- }
--
-- return M
