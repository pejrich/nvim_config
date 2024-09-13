local M = {}
local m = {}

--- Throttles a function on the leading edge. Automatically `schedule_wrap()`s.
---
--@param fn (function) Function to throttle
--@param timeout (number) Timeout in ms
--@returns (function, timer) throttled function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
local function throttle_leading(fn, ms)
  local timer = vim.loop.new_timer()
  local running = false
  -- local cached_timer = vim.loop.new_timer()
  local cached = nil

  local function wrapped_fn()
    if cached == nil or running == false then
      running = true
      cached = fn()
      -- print("cached" .. (cached or "nil"))
      -- cached_timer:start(1000, 0, function()
      --   cached = nil
      -- end)
      timer:start(ms, 0, function()
        running = false
      end)
      return cached
    else
      return cached
    end
  end
  return wrapped_fn
end
function M.setup()
  local lualine = require("lualine")

  local linemode = require("lualine.utils.mode")
  local theme = require("kanagawa.colors").setup().theme

  local throttled_command_status = throttle_leading(require("noice").api.status.command.get, 100)
  local throttled_mode_status = throttle_leading(require("noice").api.status.mode.get, 100)
  local throttled_search_status = throttle_leading(require("noice").api.status.search.get, 100)
  -- Color table for highlights
  local colors = {
    bg = theme.ui.bg_dim,
    fg = theme.ui.fg_dim,
    yellow = theme.syn.identifier,
    cyan = theme.syn.special1,
    darkblue = theme.diff.change,
    green = theme.diag.hint,
    orange = theme.diag.warning,
    violet = theme.syn.statement,
    magenta = theme.syn.number,
    blue = theme.syn.fun,
    red = theme.syn.special3,
  }

  local conditions = {
    buffer_not_empty = function()
      return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
      local filepath = vim.fn.expand("%:p:h")
      local gitdir = vim.fn.finddir(".git", filepath .. ";")
      return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
  }

  -- Config
  local config = {
    options = {
      -- Disable sections and component separators
      component_separators = "",
      section_separators = "",
      theme = {
        -- We are going to use lualine_c an lualine_x as left and
        -- right section. Both are highlighted by c theme .  So we
        -- are just setting default looks o statusline
        normal = { c = { fg = colors.fg, bg = colors.bg } },
        inactive = { c = { fg = colors.fg, bg = colors.bg } },
      },
    },
    -- extensions = { "aerial", "quickfix", "fzf", "toggleterm" },
    sections = {
      -- these are to remove the defaults
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      -- These will be filled later
      lualine_c = {},
      lualine_x = {},
    },
    inactive_sections = {
      -- these are to remove the defaults
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
  }

  -- Inserts a component in lualine_c at left section
  local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
  end

  -- Inserts a component in lualine_x at right section
  local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
  end

  ins_left({
    function()
      return "▊"
    end,
    color = { fg = colors.blue }, -- Sets highlighting of component
    padding = { left = 0, right = 1 }, -- We don't need space before this
  })
  ins_left({
    -- mode component
    function()
      local m = linemode.get_mode()
      local name = nil
      if m == "NORMAL" then
        name = " NORMAL   "
      elseif m == "O-PENDING" then
        name = " O-PENDING"
      elseif m == "VISUAL" then
        name = " VISUAL   "
      elseif m == "SELECT" then
        name = " SELECT   "
      elseif m == "INSERT" then
        name = " INSERT   "
      elseif m == "REPLACE" then
        name = " REPLACE  "
      elseif m == "COMMAND" then
        name = " COMMAND  "
      elseif m == "EX" then
        name = "   EX     "
      elseif m == "TERMINAL" then
        name = " TERMINAL "
      elseif m == "V-LINE" then
        name = " V-LINE   "
      elseif m == "V-BLOCK" then
        name = " V-BLOCK  "
      else
        name = " " .. m .. string.rep(" ", 9 - m:len())
      end
      return "" .. name
    end,
    color = function()
      -- auto change color according to neovims mode
      local mode_color = {
        n = colors.red,
        i = colors.green,
        v = colors.blue,
        [""] = colors.blue,
        V = colors.blue,
        c = colors.magenta,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        [""] = colors.orange,
        ic = colors.yellow,
        R = colors.violet,
        Rv = colors.violet,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ["r?"] = colors.cyan,
        ["!"] = colors.red,
        t = colors.red,
      }
      return { fg = mode_color[vim.fn.mode()] }
    end,
    padding = { right = 1 },
  })

  -- ins_left({
  --   -- filesize component
  --   "filesize",
  --   -- cond = conditions.buffer_not_empty,
  --   color = { fg = colors.fg },
  -- })

  ins_left({
    "harpoon2",
    indicators = { " 1 ", " 2 ", " 3 ", " 4 " },
    active_indicators = { "[1]", "[2]", "[3]", "[4]" },
    color_active = { fg = colors.blue },
    _separator = "",
    no_harpoon = "-",
  })
  ins_left({
    "filename",
    path = 1,
    -- cond = conditions.buffer_not_empty,
    color = { fg = colors.violet, gui = "bold" },
  })

  ins_left({ "location", color = { fg = colors.fg } })

  ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

  ins_left({
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " " },
    diagnostics_color = {
      error = { fg = colors.red },
      warn = { fg = colors.yellow },
      info = { fg = colors.cyan },
    },
  })

  -- Insert mid section. You can make any number of sections in neovim :)
  -- for lualine it's any number greater then 2
  ins_left({
    function()
      return "%="
    end,
  })

  ins_left({
    -- Lsp server name .
    function()
      local msg = "No Active Lsp"
      local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
      local clients = vim.lsp.get_clients()
      if next(clients) == nil then
        return msg
      end
      for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
          return client.name
        end
      end
      return msg
    end,
    icon = " LSP:",
    color = { fg = colors.fg, gui = "bold" },
  })

  ins_right({
    throttled_command_status,
    cond = function()
      return throttled_command_status() ~= nil
    end,
    color = { fg = colors.orange },
  })
  ins_right({
    throttled_mode_status,
    cond = function()
      return throttled_mode_status() ~= nil
    end,
    color = { fg = colors.orange },
  })
  ins_right({

    throttled_search_status,
    cond = function()
      return throttled_search_status() ~= nil
    end,
    color = { fg = colors.orange },
  })

  -- Add components to right sections
  ins_right({
    "o:encoding", -- option component same as &encoding in viml
    fmt = string.upper, -- I'm not sure why it's upper case either ;)
    -- cond = conditions.hide_in_width,
    color = { fg = colors.green, gui = "bold" },
  })

  ins_right({
    function()
      return "0x%04B"
    end,
    fmt = string.upper, -- I'm not sure why it's upper case either ;)
    -- cond = conditions.hide_in_width,
    color = { fg = colors.violet },
  })

  ins_right({
    "fileformat",
    fmt = string.upper,
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    color = { fg = colors.green, gui = "bold" },
  })

  ins_right({
    "branch",
    icon = "",
    color = { fg = colors.violet, gui = "bold" },
  })

  ins_right({
    "diff",
    -- Is it me or the symbol for modified us really weird
    symbols = { added = " ", modified = "󰝤 ", removed = " " },
    diff_color = {
      added = { fg = colors.green },
      modified = { fg = colors.orange },
      removed = { fg = colors.red },
    },
    -- cond = conditions.hide_in_width,
  })

  ins_right({
    function()
      return "▊"
    end,
    color = { fg = colors.blue },
    padding = { left = 1 },
  })

  -- Now don't forget to initialize lualine
  lualine.setup(config)
end

-- function M.setup()
--   local plugin = require("lualine")
--   local linemode = require("lualine.utils.mode")
--   local palette = require("theme.palette")
--   local lsp = require("plugins.lsp.lspconfig")
--
--   local diagnostics = m.diagnostics_component()
--
--   local color = {
--     active_text = palette.text,
--     incative_text = palette.faded_text,
--     inverted_text = palette.bar_bg,
--     bg = palette.bar_bg,
--     emphasized_bg = palette.lighter_gray,
--   }
--
--   local theme = {
--     normal = {
--       a = { fg = color.inverted_text, bg = palette.cyan, gui = "bold" },
--       b = { fg = color.active_text, bg = color.bg },
--       c = { fg = color.active_text, bg = color.bg },
--     },
--     command = { a = { fg = color.inverted_text, bg = palette.yellow, gui = "bold" } },
--     insert = { a = { fg = color.inverted_text, bg = palette.green, gui = "bold" } },
--     visual = { a = { fg = color.inverted_text, bg = palette.purple, gui = "bold" } },
--     terminal = { a = { fg = color.inverted_text, bg = palette.cyan, gui = "bold" } },
--     replace = { a = { fg = color.inverted_text, bg = palette.red, gui = "bold" } },
--     inactive = {
--       a = { fg = color.incative_text, bg = color.bg, gui = "bold" },
--       b = { fg = color.incative_text, bg = color.bg },
--       c = { fg = color.incative_text, bg = color.bg },
--     },
--   }
--
--   local project_section = {
--     function()
--       local fs = require("editor.fs")
--       return fs.root({ capitalize = true })
--     end,
--     color = { fg = color.inverted_text, bg = palette.cyan, gui = "bold" },
--   }
--
--   local tabs_section = {
--     "tabs",
--     mode = 1,
--     tabs_color = {
--       active = { fg = color.active_text, bg = color.emphasized_bg },
--       inactive = { fg = color.incative_text, bg = color.bg },
--     },
--   }
--
--   local mode_section = {
--     function()
--       local m = linemode.get_mode()
--       if m == "NORMAL" then
--         return "N"
--       elseif m == "VISUAL" then
--         return "V"
--       elseif m == "SELECT" then
--         return "S"
--       elseif m == "INSERT" then
--         return "I"
--       elseif m == "REPLACE" then
--         return "R"
--       elseif m == "COMMAND" then
--         return "C"
--       elseif m == "EX" then
--         return "X"
--       elseif m == "TERMINAL" then
--         return "T"
--       else
--         return m
--       end
--     end,
--   }
--
--   local filename_section = {
--     "filename",
--     path = 1,
--     color = { fg = color.active_text, bg = color.emphasized_bg },
--     fmt = function(v, _ctx)
--       if m.should_ignore_filetype() then
--         return nil
--       else
--         return v
--       end
--     end,
--   }
--
--   local branch_section = {
--     "branch",
--     color = { fg = color.active_text, bg = color.bg },
--   }
--
--   local diagnostics_section = {
--     diagnostics,
--     sections = {
--       "error",
--       "warn",
--       "info",
--       "hint",
--     },
--     colors = {
--       error = "StatusBarDiagnosticError",
--       warn = "StatusBarDiagnosticWarn",
--       info = "StatusBarDiagnosticInfo",
--       hint = "StatusBarDiagnosticHint",
--     },
--     symbols = {
--       error = lsp.signs.Error .. " ",
--       warn = lsp.signs.Warn .. " ",
--       info = lsp.signs.Info .. " ",
--       hint = lsp.signs.Hint .. " ",
--     },
--   }
--
--   local searchcount_section = "searchcount"
--
--   local encoding_section = {
--     "encoding",
--     color = { fg = color.incative_text },
--   }
--
--   local filetype_section = {
--     "filetype",
--     colored = false,
--     fmt = function(v, _ctx)
--       if m.should_ignore_filetype() then
--         return nil
--       else
--         if v == "markdown" then
--           return "md"
--         else
--           return v
--         end
--       end
--     end,
--   }
--
--   local progress_section = {
--     "progress",
--     separator = { left = "" },
--     color = { fg = color.active_text, bg = color.emphasized_bg },
--   }
--
--   local location_seciton = {
--     "location",
--     padding = { left = 0, right = 1 },
--     color = { fg = color.active_text, bg = color.emphasized_bg },
--   }
--
--   plugin.setup({
--     options = {
--       icons_enabled = true,
--       theme = theme,
--       component_separators = "",
--       section_separators = {
--         left = "",
--         -- left = "",
--         right = "",
--       },
--       disabled_filetypes = {},
--       ignore_focus = {},
--       always_divide_middle = true,
--       globalstatus = true,
--     },
--     sections = {
--       lualine_a = {
--         mode_section,
--       },
--       lualine_b = {
--         filename_section,
--         branch_section,
--         diagnostics_section,
--       },
--       lualine_c = {},
--       lualine_x = {
--         {
--           require("noice").api.status.command.get,
--           cond = require("noice").api.status.command.has,
--           color = { fg = "#ff9e64" },
--         },
--         {
--           require("noice").api.status.mode.get,
--           cond = require("noice").api.status.mode.has,
--           color = { fg = "#ff9e64" },
--         },
--         {
--           require("noice").api.status.search.get,
--           cond = require("noice").api.status.search.has,
--           color = { fg = "#ff9e64" },
--         },
--       },
--       lualine_y = {
--         searchcount_section,
--         encoding_section,
--         filetype_section,
--         progress_section,
--       },
--       lualine_z = {
--         location_seciton,
--       },
--     },
--     -- tabline = {
--     --     lualine_a = { project_section },
--     --     lualine_b = {},
--     --     lualine_c = {},
--     --     lualine_x = {},
--     --     lualine_y = {},
--     --     lualine_z = { tabs_section },
--     -- },
--   })
--
--   -- m.ensure_tabline_visibility_mode()
-- end

function M.keymaps()
  K.map({ "<M-s>", "Toggle filename in statusline", m.toggle_filename, mode = { "n", "i", "v" } })
end

function M.show()
  local plugin = require("lualine")

  plugin.hide({ unhide = true })
end

function M.hide()
  local plugin = require("lualine")

  plugin.hide()
  vim.o.laststatus = 0
  vim.o.ruler = false
end

function M.rename_tab(name)
  vim.cmd("LualineRenameTab " .. name)
end

-- Private

function m.toggle_filename()
  local plugin = require("lualine")
  local config = plugin.get_config()

  for _, section in pairs(config.sections) do
    for _, component in ipairs(section) do
      if type(component) == "table" and component[1] == "filename" then
        if component.path == 0 then
          component.path = 1
        else
          component.path = 0
        end
      end
    end
  end

  plugin.setup(config)
  m.ensure_tabline_visibility_mode()
end

function m.ensure_tabline_visibility_mode()
  -- Uncomment this if you want to show the tabline only when there are multiple tabs.
  -- This line is required because lualine overrides this setting.
  -- 0: never show tabline
  -- 1: show tabline only when there are multiple tabs
  -- 2: always show tabline
  -- vim.cmd "set showtabline=1"
end

function m.diagnostics_component()
  local diagnostics = require("lualine.components.filename"):extend()

  function diagnostics:init(options)
    diagnostics.super.init(self, options)

    self.diagnostics = {
      sections = options.sections,
      symbols = options.symbols,
      last_results = {},
      highlight_groups = {
        error = self:create_hl(options.colors.error, "error"),
        warn = self:create_hl(options.colors.warn, "warn"),
        info = self:create_hl(options.colors.info, "info"),
        hint = self:create_hl(options.colors.hint, "hint"),
      },
    }
  end

  function diagnostics:update_status()
    local context = {
      BUFFER = "buffer",
      WORKSPACE = "workspace",
    }

    local function count_diagnostics(ctx, severity)
      local bufnr

      if ctx == context.BUFFER then
        bufnr = 0
      elseif ctx == context.WORKSPACE then
        bufnr = nil
      else
        vim.print("Unexpected diagnostics context: " .. ctx)
        return nil
      end

      local total = vim.diagnostic.get(bufnr, { severity = severity })

      return vim.tbl_count(total)
    end

    local function get_diagnostic_results()
      local severity = vim.diagnostic.severity

      local results = {}

      local eb = count_diagnostics(context.BUFFER, severity.ERROR)
      local ew = count_diagnostics(context.WORKSPACE, severity.ERROR)
      if eb > 0 or ew > 0 then
        results.error = { eb, ew }
      else
        results.error = nil
      end

      local wb = count_diagnostics(context.BUFFER, severity.WARN)
      local ww = count_diagnostics(context.WORKSPACE, severity.WARN)
      if wb > 0 or ww > 0 then
        results.warn = { wb, ww }
      else
        results.warn = nil
      end

      local ib = count_diagnostics(context.BUFFER, severity.INFO)
      local iw = count_diagnostics(context.WORKSPACE, severity.INFO)
      if ib > 0 or iw > 0 then
        results.info = { ib, iw }
      else
        results.info = nil
      end

      local hb = count_diagnostics(context.BUFFER, severity.HINT)
      local hw = count_diagnostics(context.WORKSPACE, severity.HINT)
      if hb > 0 or hw > 0 then
        results.hint = { hb, hw }
      else
        results.hint = nil
      end

      for _, v in pairs(results) do
        if v ~= nil then
          return results
        end
      end

      return nil
    end

    local output = { " " }

    local bufnr = vim.api.nvim_get_current_buf()

    local diagnostics_results
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
      diagnostics_results = get_diagnostic_results()
      self.diagnostics.last_results[bufnr] = diagnostics_results
    else
      diagnostics_results = self.diagnostics.last_results[bufnr]
    end

    if diagnostics_results == nil then
      return ""
    end

    local lualine_utils = require("lualine.utils.utils")

    local colors, backgrounds = {}, {}
    for name, hl in pairs(self.diagnostics.highlight_groups) do
      colors[name] = self:format_hl(hl)
      backgrounds[name] = lualine_utils.extract_highlight_colors(colors[name]:match("%%#(.-)#"), "bg")
    end

    local previous_section, padding

    for _, section in ipairs(self.diagnostics.sections) do
      if diagnostics_results[section] ~= nil then
        padding = previous_section and (backgrounds[previous_section] ~= backgrounds[section]) and " " or ""
        previous_section = section

        local icon = self.diagnostics.symbols[section]
        local buffer_total = diagnostics_results[section][1] ~= 0 and diagnostics_results[section][1] or "-"
        local workspace_total = diagnostics_results[section][2]

        table.insert(output, colors[section] .. padding .. icon .. buffer_total .. "/" .. workspace_total)
      end
    end

    return table.concat(output, " ")
  end

  return diagnostics
end

function m.should_ignore_filetype()
  local ft = vim.bo.filetype

  return ft == "alpha"
    or ft == "noice"
    or ft == "lazy"
    or ft == "mason"
    or ft == "neo-tree"
    or ft == "TelescopePrompt"
    or ft == "lazygit"
    or ft == "DiffviewFiles"
    or ft == "spectre_panel"
    or ft == "sagarename"
    or ft == "sagafinder"
    or ft == "saga_codeaction"
end

return M
