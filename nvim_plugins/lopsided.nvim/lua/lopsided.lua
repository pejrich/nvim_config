local M = {}
local mrk = require("lopsided.marks")
local hlt = require("lopsided.highlight")

-- local utils = r:meded.utils")
local km = vim.keymap.set
-- M.augroup = vim.api:nvim_create_augroup("lopsided.nvim", { clear = true })
M.ns = vim.api.nvim_create_namespace("lopsided")
M.get_char = function()
  local ok, char = pcall(vim.fn.getcharstr)
  for _, i in ipairs({ "<CR>", "<Esc>", "<BS>" }) do
    if char == vim.api.nvim_replace_termcodes(i, true, false, true) then
      return i
    end
  end

  return char
end

-- def func(here, we, go)
-- aaaa  #{bbbb}  ccccc ddddd eeeee ffffff

-- a brde fba bce fga bce da bce dfe dgbcda
function M.init_state(in_around)
  if in_around == "around" then
    in_around = { "f", "F" }
  else
    in_around = { "t", "T" }
  end
  return { stage = "init", pos = mrk.get_curpos(), last = nil, count = 0, ia = in_around, hist = {} }
end

local rpos = nil
local lpos = nil
local fwd = "t"
local bck = "T"

function M.hlvisual()
  -- local start = vim.api.nvim_buf_get_mark(0, "<")
  -- local stop = vim.api.nvim_buf_get_mark(0, ">")
  if lpos and rpos then
    hlt.highlight_selection({ first_pos = lpos, last_pos = rpos })
  end
end

function M.perform_step(prev)
  local char = M.get_char()
  local pos = mrk.get_curpos()
  if char then
    if char == "<BS>" then
      mrk.set_curpos(prev.pos)
      M.hlvisual()
      return M.perform_step(prev)
    elseif char == "<Esc>" then
      vim.cmd("norm ``")
      M.hlvisual()
      return false
    elseif prev.stage == "init" then
      vim.cmd("norm! m`v" .. bck .. char)
      lpos = mrk.get_curpos()
      M.hlvisual()
      return M.perform_step({ char = char, pos = pos, stage = "left", prev = prev })
    elseif prev.stage == "left" then
      if char == "" or char == vim.api.nvim_replace_termcodes("<CR>", true, false, true) then
        M.hlvisual()
        return M.perform_step({ char = char, pos = pos, stage = "left", prev = prev })
      elseif char == prev.char then
        vim.cmd("norm! ;")
        lpos = mrk.get_curpos()
        M.hlvisual()
        return M.perform_step({ char = char, pos = pos, stage = "left", prev = prev })
      else
        vim.cmd("norm! o" .. fwd .. char)
        rpos = mrk.get_curpos()
        M.hlvisual()
        return M.perform_step({ char = char, pos = pos, stage = "right", prev = prev })
      end
    elseif prev.stage == "right" then
      if char == prev.char then
        vim.cmd("norm! ;")
        rpos = mrk.get_curpos()
        M.hlvisual()
        return M.perform_step({ char = char, pos = pos, stage = "right", prev = prev })
      else
        lpos = nil
        rpos = nil
        M.hlvisual()
        return char
      end
    end
  else
    M.hlvisual()
    return false
  end
end

function M.set_in_around(val)
  if val == "around" then
    fwd = "f"
    bck = "F"
  else
    fwd = "t"
    bck = "T"
  end
end

function M.start_collection()
  rpos = mrk.get_curpos()
  lpos = rpos
  local val = M.perform_step({ stage = "init", char = nil, pos = rpos, prev = nil })
  hlt.clear_highlights()
  return val
end
function M.visual_interactive(in_around)
  M.set_in_around(in_around)
  local char = M.start_collection()
  if char then
    vim.fn.feedkeys(char, "m")
  end
end

function M.delete_interactive(in_around)
  M.set_in_around(in_around)
  if M.start_collection() then
    vim.cmd("normal! d")
  end
end

function M.change_interactive(in_around)
  M.set_in_around(in_around)
  local char = M.start_collection()
  if char then
    vim.cmd("exe 'normal c" .. char .. "' | undoj | startinsert | undoj | call cursor(line('.'), col('.') + 1) | undoj")
  end
end

function M.yank_interactive(in_around)
  M.set_in_around(in_around)
  if M.start_collection() then
    vim.cmd("normal! y")
  end
end

function M.OP(args)
  print("OP " .. args)
end

function M.main() end
local hex = function(n)
  return string.format("#%06x", n)
end
--
-- -- vim.api.nvim_set_hl(0, 'IndentBlanklineContextChar',  {fg = TypeHl.fg})
-- -- vim.api.nvim_set_hl(0, 'IndentBlanklineContextStart', {sp = TypeHl.fg, underline = true})
--
function M.setup(_opts)
  -- local hl_groups = vim.api.nvim_get_hl(0, {})
  vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    callback = function()
      -- local TypeHl = vim.api.nvim_get_hl_by_name("IncSearch", true)
      -- local TypeHl2 = vim.api.nvim_get_hl_by_name("DiffDelete", true)
      -- vim.api.nvim_set_hl(0, "LopsidedHighlight", { fg = hex(TypeHl.background), bg = hex(TypeHl2.foreground) })
      vim.api.nvim_create_autocmd(
        "BufEnter",
        { group = M.augroup, desc = "Setup code for lopsided.nvim", once = true, callback = M.main }
      )
      vim.cmd([[
        " highlight default Lopsided guibg=#ff007c gui=bold ctermfg=198 cterm=bold ctermbg=darkgreen
        hi default LopsidedHighlight guifg=#1034a6 guibg=#f5f5dc ctermfg=19 ctermbg=230
      ]])
    end,
  })
  -- km("n", "va?", function()
  --   M.visual_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "ca?", function()
  --   M.change_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "da?", function()
  --   M.delete_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "ya?", function()
  --   M.yank_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "vi?", function()
  --   M.visual_interactive()
  -- end, { noremap = true, silent = true })
  -- km("n", "ci?", function()
  --   M.change_interactive()
  -- end, { noremap = true, silent = true })
  -- km("n", "di?", function()
  --   M.delete_interactive()
  -- end, { noremap = true, silent = true })
  -- km("n", "yi?", function()
  --   M.yank_interactive()
  -- end, { noremap = true, silent = true })
  -- km("n", "va<bar>", function()
  --   M.visual_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "ca<bar>", function()
  --   M.change_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "da<bar>", function()
  --   M.delete_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "ya<bar>", function()
  --   M.yank_interactive("around")
  -- end, { noremap = true, silent = true })
  -- km("n", "vi<bar>", function()
  --   M.visual_interactive()
  -- end, { noremap = true, silent = true })
  -- km("n", "ci<bar>", function()
  --   M.change_interactive()
  -- end, { noremap = true, silent = true })
  -- km("n", "di<bar>", function()
  --   M.delete_interactive()
  -- end, { noremap = true, silent = true })
  -- km("n", "yi<bar>", function()
  --   M.yank_interactive()
  -- end, { noremap = true, silent = true })
end

return M
