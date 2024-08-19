local M = {}
function M.setup()
  local Hydra = require("hydra")
  local cmd = require("hydra.keymap-util").cmd
  Hydra({
    name = "Side scroll",
    mode = "n",
    body = "z",
    heads = {
      { "h", "5zh" },
      { "l", "5zl", { desc = "←/→" } },
      { "H", "zH" },
      { "L", "zL", { desc = "half screen ←/→" } },
    },
    config = {
      hint = { type = "statusline" },
    },
  })

  --   local hint = [[
  --                  _f_: files       _m_: marks
  --    🭇🬭🬭🬭🬭🬭🬭🬭🬭🬼    _o_: old files   _g_: live grep
  --   🭉🭁🭠🭘    🭣🭕🭌🬾   _p_: projects    _/_: search in file
  --   🭅█ ▁     █🭐
  --   ██🬿      🭊██   _r_: resume      _u_: undotree
  --  🭋█🬝🮄🮄🮄🮄🮄🮄🮄🮄🬆█🭀  _h_: vim help    _c_: execute command
  --  🭤🭒🬺🬹🬱🬭🬭🬭🬭🬵🬹🬹🭝🭙  _k_: keymaps     _;_: commands history
  --                  _O_: options     _?_: search history
  --  ^
  --                  _<Enter>_: Telescope           _<Esc>_
  -- ]]
  --
  --   Hydra({
  --     name = "Telescope",
  --     hint = hint,
  --     config = {
  --       color = "teal",
  --       invoke_on_body = true,
  --       hint = {
  --         position = "middle",
  --         border = "rounded",
  --       },
  --     },
  --     mode = "n",
  --     body = "<Leader>f",
  --     heads = {
  --       { "f", cmd("Telescope find_files") },
  --       { "g", cmd("Telescope live_grep") },
  --       { "w", cmd("Telescope word") },
  --       { ".", cmd("Telescope recent files"), { desc = "recently opened files" } },
  --       { "h", cmd("Telescope help_tags"), { desc = "vim help" } },
  --       { "k", cmd("Telescope keymaps") },
  --       { "p", cmd("Telescope projects"), { desc = "projects" } },
  --       { "/", cmd("Telescope open files"), { desc = "search in file" } },
  --       { "?", cmd("Telescope search_history"), { desc = "search history" } },
  --       { ";", cmd("Telescope command_history"), { desc = "command-line history" } },
  --       { "c", cmd("Telescope commands"), { desc = "execute command" } },
  --       { "u", cmd("silent! %foldopen! | UndotreeToggle"), { desc = "undotree" } },
  --       { "<Enter>", cmd("Telescope"), { exit = true, desc = "list all pickers" } },
  --       { "<Esc>", nil, { exit = true, nowait = true } },
  --     },
  --   })
end

return M
