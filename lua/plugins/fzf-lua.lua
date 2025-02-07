local M = {}

function M.setup()
  -- calling `setup` is optional for customization
  local actions = require("fzf-lua").actions
  require("fzf-lua").setup({
    "telescope",
    previewers = { builtin = { syntax = true, syntax_limit_b = 1024 * 1024 } },
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
    actions = {
      -- Below are the default actions, setting any value in these tables will override
      -- the defaults, to inherit from the defaults change [1] from `false` to `true`
      files = {
        -- true,        -- uncomment to inherit all the below in your custom config
        -- Pickers inheriting these actions:
        --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
        --   tags, btags, args, buffers, tabs, lines, blines
        -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
        -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
        -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
        ["enter"] = actions.file_edit_or_qf,
        ["ctrl-s"] = actions.file_split,
        ["ctrl-v"] = actions.file_vsplit,
        ["ctrl-t"] = actions.file_tabedit,
        ["alt-q"] = actions.file_sel_to_qf,
        ["alt-Q"] = actions.file_sel_to_ll,
        ["alt-i"] = actions.toggle_ignore,
        ["ctrl-g"] = { actions.toggle_ignore },
        ["alt-h"] = actions.toggle_hidden,
        ["alt-f"] = actions.toggle_follow,
      },
    },
  })
end

return M
