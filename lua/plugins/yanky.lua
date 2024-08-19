local M = {}

function M.setup()
  local utils = require("yanky.utils")
  local mapping = require("yanky.telescope.mapping")
  require("yanky").setup({
    ring = {
      history_length = 100,
      storage = "shada",
      sync_with_numbered_registers = true,
      cancel_event = "update",
      ignore_registers = { "_" },
      update_register_on_cycle = true,
    },
    system_clipboard = {
      sync_with_ring = false,
    },
    highlight = {
      on_yank = false,
      on_put = false,
      -- timer = 50,
    },
    -- preserve_cursor_position = {
    --   enabled = true,
    -- },
    -- textobj = {
    --   enabled = true,
    -- },
    picker = {
      telescope = {
        mappings = {
          default = mapping.put("p"),
          i = {
            ["<c-g>"] = mapping.put("p"),
            ["<c-k>"] = mapping.put("P"),
            ["<c-x>"] = mapping.delete(),
            ["<c-r>"] = mapping.set_register(utils.get_default_register()),
          },
          n = {
            p = mapping.put("p"),
            P = mapping.put("P"),
            d = mapping.delete(),
            r = mapping.set_register(utils.get_default_register()),
          },
        },
      },
    },
  })
end

function M.keymaps()
  require("which-key").add({
    {
      "y",
      function()
        if require("noice").api.statusline.mode.get() then
          vim.api.nvim_feedkeys([["ay]], "n", true)
          return [["ay]]
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(YankyYank)", true, true, true), "m", true)
        end
      end,
      mode = { "n", "x" },
      expr = true,
      nowait = true,
    },

    {
      "p",
      function()
        if require("noice").api.statusline.mode.get() then
          vim.api.nvim_feedkeys([["ap]], "n", true)
          return [["ap]]
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(YankyPutAfter)", true, true, true), "m", true)
        end
      end,
      mode = { "n", "x" },
      expr = true,
      nowait = true,
    },
    {
      "<M-p>",
      function()
        if require("yanky").can_cycle() == true then
          require("yanky").cycle(1)
        else
          require("substitute").operator()
        end
      end,
    },
    {
      "<M-S-p>",
      function()
        require("yanky").cycle(-1)
      end,
    },
    { "PP", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },

    {
      "<A-r>",
      "<cmd>Telescope yank_history theme=cursor previewer=false<cr>",
      desc = "[Y]ank History",
      mode = { "i", "n", "x" },
    },
  })
  -- vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
  -- vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
  -- vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
  -- vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
  --
  -- vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
  -- vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
end

return M
