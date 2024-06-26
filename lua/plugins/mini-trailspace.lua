local M = {}

function M.setup()
  -- require("mini.trailspace").setup()
  -- vim.api.nvim_create_autocmd("FileType", {
  --   pattern = "tsv",
  --   callback = function(data)
  --     vim.b[data.buf].minitrailspace_disable = true
  --     vim.api.nvim_buf_call(data.buf, MiniTrailspace.unhighlight)
  --   end,
  -- })
end

return M
