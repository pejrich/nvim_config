local M = {}
M.__index = M
_G.MD = M

M.const = require("mrs_doubtfire.constants")
M.c = {
  jumper = require("mrs_doubtfire.jumper"),
  labeler = require("mrs_doubtfire.labeler"),
  cartesian = require("mrs_doubtfire.utils.cartesian"),
  prompt = require("mrs_doubtfire.prompt"),
  buffer = require("mrs_doubtfire.utils.buffer"),
  enum = require("mrs_doubtfire.utils.enum"),
  locator = require("mrs_doubtfire.locator"),
  grid = require("mrs_doubtfire.grid"),
  hl = require("mrs_doubtfire.utils.highlight"),
  keys = require("mrs_doubtfire.utils.keys"),
  search = require("mrs_doubtfire.search"),
  state = require("mrs_doubtfire.state"),
  ui = require("mrs_doubtfire.utils.ui"),
  animate = require("mrs_doubtfire.utils.animate"),
  match = require("mrs_doubtfire.match"),
  backdrop = require("mrs_doubtfire.backdrop"),
}
M.getchar = function()
  vim.cmd("redraw")
  local ok, ret = pcall(vim.fn.getchar)
  return ok and ret or nil
end

M.init_jump = function()
  M.state = M.c.state.new()
  M.c.backdrop.init()
  while true do
    local nr = M.getchar()
    local char = vim.fn.nr2char(nr)
    if M.state.is_jump_mode and char ~= "[" and char ~= "]" then
      M.terminate()
      break
    end
    if char == M.c.keys.ESC or nr == M.c.keys.ESC then
      M.terminate()
      break
    elseif char == M.c.keys.BS or nr == M.c.keys.BS then
      M.state:backspace()
    elseif char == M.c.keys.CR or nr == M.c.keys.CR then
      if M.state:confirm() then
        M.terminate()
        break
      end
    elseif M.c.keys.KEYCODE_TO_CTRL_TABLE[char] then
      if M.state:ctrl_key_pressed(M.c.keys.keycode_to_char(char)) then
        M.terminate()
        break
      end
    elseif char == "]" then
      M.state:inc_preferred_match()
    elseif char == "[" then
      M.state:dec_preferred_match()
    elseif char == "}" then
      M.state:line_inc_preferred_match()
    elseif char == "{" then
      M.state:line_dec_preferred_match()
    else
      if char:lower() == char then
        M.state:insert_forward(char)
      elseif char:upper() == char then
        M.state:insert_backward(char)
      end
    end
  end
end

function M.set_jump_mode()
  M.c.jumper.set_jump_mode()
  M.state.is_jump_mode = true
end

function M.terminate()
  M.cleanup()

  M.state = nil
end

function M.cleanup()
  M.c.grid.remove_border_guides()
  M.c.grid.cleanup()
  M.c.state.cleanup()
  M.c.state.clear_hl()
  M.c.jumper.cleanup()
  M.c.backdrop.cleanup()
  if M.state then
    M.state:cleanup()
  end
end
-- function M.jump_fwd(count)
--   local info = MD.c.jumper.jump_to_prev(count)
--   local diff = 60 * ((info.current - 1) / info.total)
--   local after = math.floor(60 - diff)
--   local before = math.ceil(diff)
--   local display = string.rep(" ", 5)
--     .. "|1|"
--     .. string.rep("-", before)
--     .. " |"
--     .. info.current
--     .. "| "
--     .. string.rep("-", after)
--     .. "|"
--     .. info.total
--     .. "|"
--     .. string.rep(" ", 5)
--   MD.c.prompt.set(display)
-- end

-- function M.jump_bwd(count)
--   local info = MD.c.jumper.jump_to_prev(count * -1)
-- end
M.load_highlights = function()
  vim.api.nvim_set_hl(
    0,
    "MD_TargetMatch",
    { fg = "#dcd7ba", bg = "#2d4f67", sp = "#e69039", underline = true, force = true, bold = false, default = true }
  )

  vim.api.nvim_set_hl(0, "MD_GhostTargetMatch", { sp = "#e69039", underline = true, force = true, default = true })
  vim.api.nvim_set_hl(
    0,
    "MD_LabeledMatch",
    { fg = "#dcd7ba", bg = "#2d4f67", sp = "#c34043", underline = true, force = true, bold = true, default = true }
  )
  vim.api.nvim_set_hl(
    0,
    "MD_PreferredTargetMatch",
    { fg = "#dcd7ba", bg = "#c34043", sp = "#e69039", underline = true, force = true, bold = true, default = true }
  )

  vim.api.nvim_set_hl(0, "MD_Trail_1", { fg = "#223249", bg = "#FF9E3B", force = true, default = true })
  vim.api.nvim_set_hl(0, "MD_Trail_2", { fg = "#223249", bg = "#DD8A38", force = true, default = true })
  vim.api.nvim_set_hl(0, "MD_Trail_3", { fg = "#223249", bg = "#BA7536", force = true, default = true })
  vim.api.nvim_set_hl(0, "MD_Trail_4", { fg = "#223249", bg = "#986133", force = true, default = true })
  vim.api.nvim_set_hl(0, "MD_Trail_5", { fg = "#223249", bg = "#764C30", force = true, default = true })

  local links = {
    -- FlashBackdrop = "Comment",
    --
    -- TargetMatch = "Search",
    MD_FinalTargetMatch = "IncSearch",
    -- PreferredTargetMatch = "Substitute",
    -- FlashPrompt = "MsgArea",
    MD_BackwardMatches = "Boolean",
    MD_ForwardMatches = "Boolean",
    -- FlashCursor = "Cursor",
  }
  for hl_group, link in pairs(links) do
    vim.api.nvim_set_hl(0, hl_group, { link = link, default = true })
  end
end
local hl = { "Substitute", "@keyword.exception", "@diff.minus" }
local fwdns = vim.api.nvim_create_namespace("mrs.fwd")
M.init_fwd = function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local text = vim.api.nvim_buf_get_text(0, pos[1] - 1, pos[2] + 1, pos[1] + 2, 1, {})
  local state = {}
  local line = pos[1] - 1
  local col = pos[2] + 1
  for _, row in ipairs(text) do
    for i = 1, #row do
      local count = state[row:sub(i, i)] or 0
      if count <= 2 then
        print(row:sub(i, i) .. " " .. line .. " " .. (i - 1))
        -- vim.notify("adding " .. row:sub(i, i))
        vim.api.nvim_buf_set_extmark(
          0,
          fwdns,
          line,
          col,
          { strict = true, hl_group = hl[count + 1], end_col = col + 1 }
        )
        -- vim.api.nvim_buf_set_extmark(0, fwdns, line, i, { strict = true, hl_group = hl[count], end_col = i + 1 })
        state[row:sub(i, i)] = count + 1
      end
      col = col + 1
    end
    line = line + 1
    col = 0
  end
end
M.setup = function(opts)
  -- vim.keymap.set("n", "//", "?")
  vim.keymap.set("n", "//", M.init_jump)
  -- vim.keymap.set("n", "f", M.init_fwd)
  -- vim.keymap.set("n", "//]", function()
  --   M.jump_fwd(math.max(vim.v.count, 1))
  -- end)
  -- vim.keymap.set("n", "//[", function()
  --   M.jump_bwd(math.max(vim.v.count, 1))
  -- end)
  M.load_highlights()
  vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    callback = function()
      M.load_highlights()
    end,
  })
end

vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  callback = function()
    M.load_highlights()
  end,
})
M.load_highlights()
-- vim.api.nvim_set_hl(
--   0,
--   "MD_TargetMatch",
--   { fg = "#dcd7ba", bg = "#2d4f67", sp = "#e69039", underline = true, force = true, bold = false, default = true }
-- )
--
-- vim.api.nvim_set_hl(0, "MD_GhostTargetMatch", { sp = "#e69039", underline = true, force = true, default = true })
-- vim.api.nvim_set_hl(
--   0,
--   "MD_LabeledMatch",
--
--   { fg = "#dcd7ba", bg = "#2d4f67", sp = "#c34043", underline = true, force = true, bold = true, default = true }
-- )
-- vim.api.nvim_set_hl(
--   0,
--   "MD_PreferredTargetMatch",
--   { fg = "#dcd7ba", bg = "#c34043", sp = "#e69039", underline = true, force = true, bold = true, default = true }
-- )
--
-- local links = {
--   -- FlashBackdrop = "Comment",
--   --
--   -- TargetMatch = "Search",
--   MD_FinalTargetMatch = "IncSearch",
--   -- PreferredTargetMatch = "Substitute",
--   -- FlashPrompt = "MsgArea",
--   MD_BackwardMatches = "Boolean",
--   MD_ForwardMatches = "Boolean",
--   -- FlashCursor = "Cursor",
-- }
-- for hl_group, link in pairs(links) do
--   vim.api.nvim_set_hl(0, hl_group, { link = link, default = true })
-- end
return M
