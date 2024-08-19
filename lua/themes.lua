local M = {
  {
    "aktersnurra/no-clown-fiesta.nvim",
  },
  {
    "ellisonleao/gruvbox.nvim",
  },
  {
    "EdenEast/nightfox.nvim",
  },
  {
    "AlexvZyl/nordic.nvim",
  },
  {
    "projekt0n/github-nvim-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        -- ...
      })

      -- vim.cmd("colorscheme github_dark")
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    config = function()
      require("kanagawa").setup({
        overrides = function(colors)
          return {
            Visual = { bg = "#E69039", fg = "#223249" },
            BufferCurrentSign = { fg = colors.theme.syn.special2, bg = colors.theme.ui.bg },
            BufferCurrent = { fg = colors.theme.syn.special2, bg = colors.theme.ui.bg },
            BufferCurrentMod = { fg = colors.theme.syn.special2, bg = colors.theme.ui.bg },
            BufferDefaultVisibleMod = { fg = colors.theme.syn.special2, bg = colors.theme.ui.bg },
            BufferCurrentIcon = { fg = colors.theme.syn.special2, bg = colors.theme.ui.bg },
            BufferCurrentDefault = { fg = colors.theme.syn.special2, bg = colors.theme.ui.bg },
            BufferCurrentIndex = { fg = colors.theme.syn.special2, bg = colors.theme.ui.bg },
            BufferAlternateSign = { fg = colors.theme.syn.parameter, bg = colors.theme.ui.bg_m3 },
            BufferAlternateIndex = { fg = colors.theme.syn.string, bg = colors.theme.ui.bg_m3 },
            BufferAlternate = { fg = colors.theme.syn.parameter, bg = colors.theme.ui.bg_m3 },
            BufferVisibleSign = { fg = colors.theme.syn.fun, bg = colors.theme.ui.bg_m3 },
            BufferVisibleIndex = { fg = colors.theme.syn.string, bg = colors.theme.ui.bg_m3 },
            BufferVisible = { fg = colors.theme.syn.fun, bg = colors.theme.ui.bg_m3 },
          }
        end,
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
      })
      vim.opt.termguicolors = true
      vim.cmd("colorscheme kanagawa")
    end,
  },
}

return M
