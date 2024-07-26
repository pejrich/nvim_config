local M = {}

function M.setup()
  require("trouble").setup({})
end

function M.keymaps()
  local t = require("trouble")
  require("which-key").add({
    { "<leader>x", group = "Trouble/Diagnostics" },
    {
      "<leader>xx",
      function()
        t.toggle()
      end,
      desc = "Toggle",
    },
    {
      "<leader>xw",
      function()
        t.toggle("workspace_diagnostics")
      end,
      desc = "[W]orkspace diagnostics",
    },
    {
      "<leader>xd",
      function()
        t.toggle("document_diagnostics")
      end,
      desc = "[D]ocument diagnostics",
    },
    {
      "<leader>xq",
      function()
        t.toggle("quickfix")
      end,
      desc = "[Q]uickfix",
    },
    {
      "<leader>xl",
      function()
        t.toggle("loclist")
      end,
      desc = "[L]oclist",
    },
    {
      "<leader>xr",
      function()
        t.toggle("lsp_references")
      end,
      desc = "[R]eferences",
    },
  })
end
return M
