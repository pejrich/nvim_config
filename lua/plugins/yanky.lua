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
  -- vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
  -- vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
  -- vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
  -- vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
  --
  -- vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
  -- vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
end

return M
