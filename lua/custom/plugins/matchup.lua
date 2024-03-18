local M = {
  {
    'andymass/vim-matchup',
    event = { 'BufReadPost' },
    setup = function()
      vim.o.matchpairs = '(:),{:},[:]'
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },
}
return M
