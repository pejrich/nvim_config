local M = {}
function M.setup()
  require("aerial").setup({
    -- optionally use on_attach to set keymaps when aerial has attached to a buffer
    on_attach = function(bufnr)
      -- Jump forwards/backwards with '{' and '}'
      vim.keymap.set("n", "<M-{>", "<cmd>AerialPrev<CR>", { buffer = bufnr })
      vim.keymap.set("n", "<M-}>", "<cmd>AerialNext<CR>", { buffer = bufnr })
    end,
  })
end

function M.keymaps()
  K.map({ "<leader>a", "Toggle Aerial", "<cmd>AerialToggle!<CR>", mode = { "n" } })
end

return M
