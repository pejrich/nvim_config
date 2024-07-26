local trim_leading
trim_leading = function(string)
  if string:sub(1, 1) == " " then
    return trim_leading(string:sub(2, #string))
  else
    return string
  end
end

local trim_trailing
trim_trailing = function(string)
  if string:sub(#string, #string) == " " then
    return trim_trailing(string:sub(1, #string - 1))
  else
    return string
  end
end
-- Return to same cursor position after canceling visual selection with <esc>
vim.cmd([[
  execute "nnoremap v m9v"
  execute "nnoremap V m9V"
  execute "nnoremap <C-v> m9<C-v>"
  execute "vnoremap <esc> <esc>`9"
  execute "vnoremap <cr> <esc>"
]])
vim.keymap.del({ "n" }, "gcc")
-- Change norm `C` to function like the opposite of norm `D`. C deletes to start of line, D deletes to end of line
vim.cmd([[
  nnoremap <silent> C :<c-u>normal! d^<cr>
]])
local dmmns = vim.api.nvim_create_namespace("dontmoveme")
local function dont_move_me(fn)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ext = vim.api.nvim_buf_set_extmark(0, dmmns, cursor[1] - 1, cursor[2], {})
  fn()
  local extcursor = vim.api.nvim_buf_get_extmark_by_id(0, dmmns, ext, {})
  vim.api.nvim_win_set_cursor(0, { extcursor[1] + 1, extcursor[2] })
  vim.api.nvim_buf_clear_namespace(0, dmmns, 0, -1)
end
-- one     twwtwwo        three
-- ycdv in/around the current line
-- vim.cmd([[
--   nnoremap <silent> yil :<c-u>normal! m`^y$``<cr>
--   nnoremap <silent> yal :<c-u>normal! m`0y$``<cr>
--   nnoremap <silent> val :<c-u>normal! 0v$<cr>
--   nnoremap <silent> vil :<c-u>normal! ^v$<cr>
--   nnoremap <silent> dil :<c-u>normal! ^D<cr>
--   nnoremap <silent> dal :<c-u>normal! 0D<cr>
--   nnoremap <silent> cil :<c-u>normal! ^D<cr>a
--   nnoremap <silent> cal :<c-u>normal! 0D<cr>a
-- ]])
-- vim.cmd([[
--   onoremap <silent> il :<c-u>normal! $v^<cr>
-- ]])
-- dai - Delete around inside
vim.keymap.set("n", "dai", function()
  dont_move_me(function()
    vim.cmd("norm f da F da ")
  end)
end)
vim.keymap.set("n", "dii", function()
  dont_move_me(function()
    vim.cmd("norm f di F F di ")
  end)
end)

vim.keymap.set("n", "dna", function()
  require("editor.functions").remove_function_arg(vim.v.count)
end)

vim.keymap.set("n", "vv", function()
  vim.fn.feedkeys("m`")
  require("nvim-treesitter.incremental_selection").init_selection()
end)

require("editor.editing").keymaps()
-- require("editor.buffers").keymaps()
-- require("editor.windows").keymaps()
require("editor.terminal").keymaps()
require("editor.debug").keymaps()

-- Plugins
require("plugins.lazy").keymaps()

require("plugins.noice").keymaps()
require("plugins.aerial").keymaps()
require("plugins.flash").keymaps()
require("plugins.comment").keymaps()
require("plugins.conform").keymaps()
require("plugins.lint").keymaps()
require("plugins.crates").keymaps()
require("plugins.telescope").keymaps()
require("plugins.treesitter").keymaps()
require("plugins.harpoon").keymaps()
require("plugins.trouble").keymaps()
require("plugins.spectre").keymaps()
require("plugins.lualine").keymaps()
require("plugins.neo-tree").keymaps()
require("plugins.persistence").keymaps()
require("plugins.yanky").keymaps()
require("plugins.toggleterm").keymaps()
require("plugins.lsp.mason").keymaps()
require("plugins.lsp.lspsaga").keymaps()
require("plugins.lsp.lsp-lines").keymaps()
require("plugins.git.lazygit").keymaps()
require("plugins.git.fugit2").keymaps()
require("plugins.git.gitsigns").keymaps()
require("plugins.git.diffview").keymaps()
require("plugins.nvim-spider").keymaps()

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local function elixir_picker(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "Elixir Picker",
      finder = finders.new_table({
        results = { "contract", "expand" },
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.api.nvim_put({ selection[1] }, "", false, true)
        end)
        return true
      end,
    })
    :find()
end

local wk = require("which-key")
local l = function(key)
  return "<leader>" .. key
end
wk.add({
  { l("e"), group = "[E]lixir" },
  {
    l("ee"),
    function()
      elixir_picker(require("telescope.themes").get_dropdown({}))
    end,
    desc = "[E]lixir Picker",
  },
  { l("ed"), '<cmd>lua require("elixir-extras").elixir_view_docs({include_mix_libs=true})<cr>', desc = "[E]lixir [D]ocs" },
  { l("em"), '<cmd>lua require("elixir-extras").module_complete()<cr>', desc = "[E]lixir Complete [M]odule" },
  { l("d"), group = "[D]ocument" },
  { l("do"), "<cmd>!open -R %:p<cr>", desc = "[O]pen in Finder" },
  { l("df"), group = "[F]ormat" },
  { l("dfj"), "<cmd>%!jq<cr>", desc = "[J]SON" },
  { l("dfe"), "<cmd>!mix format %:p<cr>", desc = "[E]lixir" },
  { l("g"), group = "[G]o to" },
  { l("gd"), "<cmd>Lspsaga goto_definition<cr>", desc = "[G]o to [D]efinition" },
  { l("gpd"), "<cmd>Lspsaga peek_definition<cr>", desc = "[G]o [P]eek [D]efinition" },
  { l("goo"), "<cmd>Lspsaga outline<cr><C-h><C-l>", desc = "[G]o [O]pen [O]utline" },
  { l("f"), group = "[F]ind/Files" },
  { l("fz"), "<cmd>FzfLua builtin<cr>", desc = "[F]ind F[Z]FLua builtin" },
  { l("ff"), "<cmd>FzfLua files<cr>", desc = "[F]ind [F]iles" },
  { l("fb"), "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>", desc = "[F]ile [B]rowser" },
  { l("m"), group = "[M]odify" },
  { l("mw"), group = "[W]hitespace" },
  { l("mwl"), "<cmd>s/^ *//g<cr>", desc = "[L]eading", mode = "v" },
  { l("mwt"), "<cmd>s/ *$//g<cr>", desc = "[T]railing", mode = "v" },
  { l("<leader>"), group = "Misc" },
  { l(l("x")), "<cmd>w<cr><cmd>source %<cr>", desc = "E[x]ec file" },
  { l(l("p")), group = "[P]rofile" },
  { l(l("pf")), F.start_flame_profile, desc = "Start [P]rofile [F]lame" },
  { l(l("ps")), F.start_profile, desc = "Start [P]rofile" },
  { l(l("pe")), F.stop_profile, desc = "Profile [E]nd" },
  { l(l("f")), group = "[F]ile" },
  { l(l("fc")), F.copy_file_path, desc = "[C]opy [F]ile Path" },
  { l(l("fdd")), F.delete_file_path, desc = "[DD]elete Current [F]ile" },
  { l("q"), "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>", desc = "[Q]uit buffer" },
  { l("1"), "<cmd>BufferLineGoToBuffer 1<cr>", desc = "[B]uffer [1]" },
  { l("2"), "<cmd>BufferLineGoToBuffer 2<cr>", desc = "[B]uffer [2]" },
  { l("3"), "<cmd>BufferLineGoToBuffer 3<cr>", desc = "[B]uffer [3]" },
  { l("4"), "<cmd>BufferLineGoToBuffer 4<cr>", desc = "[B]uffer [4]" },
  { l("5"), "<cmd>BufferLineGoToBuffer 5<cr>", desc = "[B]uffer [5]" },
  { l("6"), "<cmd>BufferLineGoToBuffer 6<cr>", desc = "[B]uffer [6]" },
  { l("7"), "<cmd>BufferLineGoToBuffer 7<cr>", desc = "[B]uffer [7]" },
  { l("8"), "<cmd>BufferLineGoToBuffer 8<cr>", desc = "[B]uffer [8]" },
  { l("9"), "<cmd>BufferLineGoToBuffer 9<cr>", desc = "[B]uffer [9]" },
  { l("["), "<cmd>BufferLineCyclePrev<cr>", desc = "[B]uffer [P]rev" },
  { l("]"), "<cmd>BufferLineCycleNext<cr>", desc = "[B]uffer [N]ext" },
  { l("s"), group = "[S]ubstitute/[S]cratch" },
  { l("so"), require("substitute").operator, desc = "[O]perator" },
  { l("sl"), require("substitute").line, desc = "[L]ine" },
  { l("se"), require("substitute").eol, desc = "[E]nd of line" },
  { l("si"), "<Plug>(scratch-insert-reuse)", desc = "[I]nsert" },
  { l("sp"), "<cmd>ScratchPreview<CR>", desc = "[P]review" },
  { l("ss"), "<cmd>Scratch<CR>", desc = "[S]cratch" },
})

local delim_map = { ["("] = 1, [")"] = 1, ["{"] = 1, ["}"] = 1, ["["] = 1, ["]"] = 1, ['"'] = 1, ["'"] = 1, [""] = 1 }
vim.keymap.set("v", "<leader>da", function()
  local vstart = vim.fn.getpos("'<")

  local _, srow, scol = unpack(vim.fn.getpos("v"))
  local _, erow, ecol = unpack(vim.fn.getpos("."))
  if srow > erow or (srow == erow and scol > ecol) then
    local pivot = srow
    srow = erow
    erow = pivot
    pivot = scol
    scol = ecol
    ecol = pivot
  end
  local text = table.concat(vim.api.nvim_buf_get_text(0, srow - 1, math.max(0, scol - 1), erow - 1, ecol, {}), "\n")
  local before = vim.api.nvim_buf_get_text(0, srow - 1, math.max(0, scol - 2), srow - 1, math.max(0, scol - 1), {})
  local after = vim.api.nvim_buf_get_text(0, erow - 1, ecol, erow - 1, ecol + 1, {})

  if delim_map[before[1]] == 1 then
    text = trim_leading(text)
  else
    if text:sub(1, 1) == " " then
      text = trim_leading(text)
      text = " " .. text
    end
  end
  if delim_map[after[1]] == 1 then
    text = trim_trailing(text)
  else
    if text:sub(#text, #text) == " " then
      text = trim_trailing(text)
      text = text .. " "
    end
  end

  local max_width = #vim.api.nvim_buf_get_lines(0, srow - 1, srow, false)[1]
  vim.api.nvim_buf_set_text(0, srow - 1, math.max(0, scol - 1), erow - 1, math.min(max_width, ecol), { text })
end)

vim.keymap.set("n", "<M-Del>", function()
  vim.cmd("Noice dismiss")
end)

vim.keymap.set("n", "<M-BS>", function()
  vim.cmd("Noice dismiss")
end)

wk.add({
  { "<C-s>", require("substitute").operator, desc = "[S]ubstitute [O]perator" },
  { "<leader>s", require("substitute").visual, desc = "[S]ubstitute Visual", mode = { "x" } },
  { "<leader>i", "<Plug>(scratch-selection-reuse)<CR>", desc = "[I]nsert", mode = { "x" } },
})

-- wk.register(WK, { prefix = "<leader>" })
-- wk.register(WKN, {})

vim.keymap.set({ "n" }, "\\\\gv", "<Plug>(VM-Reselect-Last)<cr>", { desc = "Multicursor Reselelect Last" })
-- vim.keymap.set({ "n" }, "<C-p>", "<cmd>FzfLua files<cr>", { desc = "Find Files" })
vim.keymap.set({ "n" }, "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set({ "n" }, "<C-S-p>", "<cmd>Telescope buffers<cr>", { desc = "Buffer Select" })
vim.keymap.set({ "n" }, "<C-f>", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set({ "n" }, "U", "<C-r><CR>", { desc = "Redo" })
vim.keymap.set({ "n" }, "<M-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set({ "n" }, "<M-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set({ "i" }, "<M-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set({ "i" }, "<M-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set({ "v" }, "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set({ "v" }, "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set({ "i" }, "<esc>", "<C-[>", { desc = "Escape" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- vim.cmd([[
-- nnoremap <M-j> :m .+1<CR>==
-- nnoremap <M-k> :m .-2<CR>==
-- inoremap <M-j> <Esc>:m .+1<CR>==gi
-- inoremap <M-k> <Esc>:m .-2<CR>==gi
-- vnoremap <M-j> :m '>+1<CR>gv=gv
-- vnoremap <M-k> :m '<-2<CR>gv=gv
-- ]])
