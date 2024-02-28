local M = {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      require('telescope').setup({
        pickers = {
          find_files = {
            theme = "dropdown",
          }
        },
        defaults = {
          layout_config = {
            vertical = { width = 0.8, height = 0.99 },
            horizontal = { width = 0.99, height = 0.5 },
            center = { width = 0.99, height = 0.99 },
          },
        },
      })
      require('telescope').load_extension('fzf')
    end,
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
}
return M
