local wk = require 'which-key'

wk.register({
  g = {
    name = 'Go to',
    d = { '<cmd>Lspsaga goto_definition<cr>', '[G]o to [D]efinition' },
    p = {
      d = { '<cmd>Lspsaga peek_definition<cr>', '[G]o [P]eek [D]efinition' },
    },
    o = {
      o = { '<cmd>Lspsaga outline<cr><C-h><C-l>', '[G]o [O]pen [O]utline' },
    },
  },
  f = {
    name = 'Find',
    f = { '<cmd>Telescope find_files<cr>', '[F]ind [F]iles' },
  },
  b = {
    name = 'Buffer',
    s = { '<cmd>BufferLinePick<cr>', '[B]uffer [S]elect' },
    c = { '<cmd>BufferLinePickClose<cr>', '[B]uffer Select to [C]lose' },
    n = { '<cmd>BufferLineCycleNext<cr>', '[B]uffer [N]ext' },
    p = { '<cmd>BufferLineCyclePrev<cr>', '[B]uffer [P]rev' },
    ['1'] = { '<cmd>BufferLineGoToBuffer 1<cr>', '[B]uffer [1]' },
    ['2'] = { '<cmd>BufferLineGoToBuffer 2<cr>', '[B]uffer [2]' },
    ['3'] = { '<cmd>BufferLineGoToBuffer 3<cr>', '[B]uffer [3]' },
    ['4'] = { '<cmd>BufferLineGoToBuffer 4<cr>', '[B]uffer [4]' },
    ['5'] = { '<cmd>BufferLineGoToBuffer 5<cr>', '[B]uffer [5]' },
    ['6'] = { '<cmd>BufferLineGoToBuffer 6<cr>', '[B]uffer [6]' },
    ['7'] = { '<cmd>BufferLineGoToBuffer 7<cr>', '[B]uffer [7]' },
    ['8'] = { '<cmd>BufferLineGoToBuffer 8<cr>', '[B]uffer [8]' },
    ['9'] = { '<cmd>BufferLineGoToBuffer 9<cr>', '[B]uffer [9]' },
  },
  q = { '<cmd>bp<bar>sp<bar>bn<bar>bd<CR>', '[Q]uit buffer' },
  -- vim.api.nvim_set_keymap('n', '<leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>', { desc = 'Close buffer' })
}, { prefix = '<leader>' })
