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
    name = 'Find/Files',
    f = { '<cmd>Telescope find_files<cr>', '[F]ind [F]iles' },
    b = { '<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>', '[F]ile [B]rowser' },
  },
  m = {
    name = '[M]odify',
    w = {
      name = '[W]hitespace',
      l = { '<cmd>s/^ *//g<cr>', '[L]eading', mode = 'v' },
      t = { '<cmd>s/ *$//g<cr>', '[T]railing', mode = 'v' },
    },
  },
  b = {
    name = 'Buffer',
    s = { '<cmd>BufferLinePick<cr>', '[B]uffer [S]elect' },
    c = { '<cmd>BufferLinePickClose<cr>', '[B]uffer Select to [C]lose' },
    n = { '<cmd>BufferLineCycleNext<cr>', '[B]uffer [N]ext' },
    p = { '<cmd>BufferLineCyclePrev<cr>', '[B]uffer [P]rev' },
  },
  q = { '<cmd>bp<bar>sp<bar>bn<bar>bd<CR>', '[Q]uit buffer' },
  ['1'] = { '<cmd>BufferLineGoToBuffer 1<cr>', '[B]uffer [1]' },
  ['2'] = { '<cmd>BufferLineGoToBuffer 2<cr>', '[B]uffer [2]' },
  ['3'] = { '<cmd>BufferLineGoToBuffer 3<cr>', '[B]uffer [3]' },
  ['4'] = { '<cmd>BufferLineGoToBuffer 4<cr>', '[B]uffer [4]' },
  ['5'] = { '<cmd>BufferLineGoToBuffer 5<cr>', '[B]uffer [5]' },
  ['6'] = { '<cmd>BufferLineGoToBuffer 6<cr>', '[B]uffer [6]' },
  ['7'] = { '<cmd>BufferLineGoToBuffer 7<cr>', '[B]uffer [7]' },
  ['8'] = { '<cmd>BufferLineGoToBuffer 8<cr>', '[B]uffer [8]' },
  ['9'] = { '<cmd>BufferLineGoToBuffer 9<cr>', '[B]uffer [9]' },
  ['['] = { '<cmd>BufferLineCycleNext<cr>', '[B]uffer [P]rev' },
  [']'] = { '<cmd>BufferLineCycleNext<cr>', '[B]uffer [N]ext' },
  -- vim.api.nvim_set_keymap('n', '<leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>', { desc = 'Close buffer' })
}, { prefix = '<leader>' })

vim.api.nvim_set_keymap('n', '<A-j>', '<cmd>m .+1<CR>==', { desc = 'Move line down' })
vim.api.nvim_set_keymap('n', '<A-k>', '<cmd>m .-2<CR>==', { desc = 'Move line up' })
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc><cmd>m .+1<CR>==gi', { desc = 'Move line down' })
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc><cmd>m .-2<CR>==gi', { desc = 'Move line up' })

-- vim.api.nvim_set_keymap('ni', 'C-1', )
-- vim.api.nvim_set_keymap('n', '<C-2>', '<cmd>BufferLineGoToBuffer 2<cr>', { desc = '[B]uffer [2]' })
-- vim.api.nvim_set_keymap('n', '<C-3>', '<cmd>BufferLineGoToBuffer 3<cr>', { desc = '[B]uffer [3]' })
-- vim.api.nvim_set_keymap('n', '<C-4>', '<cmd>BufferLineGoToBuffer 4<cr>', { desc = '[B]uffer [4]' })
-- vim.api.nvim_set_keymap('n', '<C-5>', '<cmd>BufferLineGoToBuffer 5<cr>', { desc = '[B]uffer [5]' })
-- vim.api.nvim_set_keymap('n', '<C-6>', '<cmd>BufferLineGoToBuffer 6<cr>', { desc = '[B]uffer [6]' })
-- vim.api.nvim_set_keymap('n', '<C-7>', '<cmd>BufferLineGoToBuffer 7<cr>', { desc = '[B]uffer [7]' })
-- vim.api.nvim_set_keymap('n', '<C-8>', '<cmd>BufferLineGoToBuffer 8<cr>', { desc = '[B]uffer [8]' })
-- vim.api.nvim_set_keymap('n', '<C-9>', '<cmd>BufferLineGoToBuffer 9<cr>', { desc = '[B]uffer [9]' })
