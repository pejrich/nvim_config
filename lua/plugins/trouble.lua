local M = {}

function M.setup()
  require("trouble").setup({})
end

function M.keymaps()
  local t = require("trouble")
  K.merge_wk({
    x = {
      name = "Trouble/Diagnostics",
      x = {
        function()
          t.toggle()
        end,
        "Toggle",
      },
      w = {
        function()
          t.toggle("workspace_diagnostics")
        end,
        "[W]orkspace diagnostics",
      },
      d = {
        function()
          t.toggle("document_diagnostics")
        end,
        "[D]ocument diagnostics",
      },
      q = {
        function()
          t.toggle("quickfix")
        end,
        "[Q]uickfix",
      },
      l = {
        function()
          t.toggle("loclist")
        end,
        "[L]oclist",
      },
      r = {
        function()
          t.toggle("lsp_references")
        end,
        "[R]eferences",
      },
    },
  })
end
return M
