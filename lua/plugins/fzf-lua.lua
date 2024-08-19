local M = {}

function M.setup()
  -- calling `setup` is optional for customization
  require("fzf-lua").setup({
    "telescope",
    previewers = { builtin = { syntax = true, syntax_limit_b = 0 } },
    files = { cmd = "rg --files --hidden", multiprocess = true, file_icons = true, git_icons = false, color_icons = true },
    grep = { multiprocess = true, file_icons = true, git_icons = true, color_icons = true },
    buffers = {
      file_icons = true, -- show file icons?
      color_icons = true, -- colorize file|git icons
      sort_lastused = true,
    },
    winopts = {
      preview = {
        delay = 350,
      },
    },
  })
end

return M
