-- Return to same cursor position after canceling visual selection with <esc>
vim.cmd([[
  execute "nnoremap v m`v"
  execute "nnoremap V m`V"
  execute "nnoremap <C-v> m`<C-v>"
  execute "vnoremap <esc> <esc>``"
  execute "vnoremap <cr> <esc>"
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
vim.cmd([[
  nnoremap <silent> yil :<c-u>normal! m`^y$``<cr>
  nnoremap <silent> yal :<c-u>normal! m`0y$``<cr>
  nnoremap <silent> val :<c-u>normal! 0v$<cr>
  nnoremap <silent> vil :<c-u>normal! ^v$<cr>
  nnoremap <silent> dil :<c-u>normal! ^D<cr>
  nnoremap <silent> dal :<c-u>normal! 0D<cr>
  nnoremap <silent> cil :<c-u>normal! ^D<cr>a
  nnoremap <silent> cal :<c-u>normal! 0D<cr>a
]])
vim.cmd([[
  onoremap <silent> il :<c-u>normal! $v^<cr>
]])
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
          -- print(vim.inspect(selection))
          vim.api.nvim_put({ selection[1] }, "", false, true)
        end)
        print(vim.inspect(prompt_bufnr))
        print(vim.inspect(map))
        return true
      end,
    })
    :find()
end

local wk = require("which-key")
K.merge_wk({
  e = {
    name = "[E]lixir",
    e = {
      function()
        elixir_picker(require("telescope.themes").get_dropdown({}))
      end,
      "[E]lixir Picker",
    },
    d = { '<cmd>lua require("elixir-extras").elixir_view_docs({include_mix_libs=true})<cr>', "[E]lixir [D]ocs" },
    m = {
      '<cmd>lua require("elixir-extras").module_complete()<cr>',
      "[E]lixir Complete [M]odule",
    },
  },
  d = {
    f = {
      name = "[F]ormat",
      j = { "<cmd>%!jq<cr>", "[J]SON" },
      e = { "<cmd>!mix format %:p<cr>", "[E]lixir" },
    },
  },
  g = {
    name = "[G]o to",
    d = { "<cmd>Lspsaga goto_definition<cr>", "[G]o to [D]efinition" },
    p = {
      d = { "<cmd>Lspsaga peek_definition<cr>", "[G]o [P]eek [D]efinition" },
    },
    o = {
      o = { "<cmd>Lspsaga outline<cr><C-h><C-l>", "[G]o [O]pen [O]utline" },
    },
  },
  f = {
    name = "[F]ind/Files",
    -- f = { '<cmd>Telescope find_files<cr>', '[F]ind [F]iles' },
    z = { "<cmd>FzfLua builtin<cr>", "[F]ind F[Z]FLua builtin" },
    f = { "<cmd>FzfLua files<cr>", "[F]ind [F]iles" },
    b = { "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>", "[F]ile [B]rowser" },
  },
  m = {
    name = "[M]odify",
    w = {
      name = "[W]hitespace",
      l = { "<cmd>s/^ *//g<cr>", "[L]eading", mode = "v" },
      t = { "<cmd>s/ *$//g<cr>", "[T]railing", mode = "v" },
    },
  },
  ["<leader>"] = {
    name = "Misc",
    x = { "<cmd>w<cr><cmd>source %<cr>", "E[x]ec file" },
    p = {
      name = "[P]rofile",
      f = { F.start_flame_profile, "Start [P]rofile [F]lame" },
      s = { F.start_profile, "Start [P]rofile" },
      e = { F.stop_profile, "Profile [E]nd" },
    },
    f = {
      name = "[F]ile",
      c = { F.copy_file_path, "[C]opy [F]ile Path" },
      ["dd"] = { F.delete_file_path, "[DD]elete Current [F]ile" },
    },
  },
  q = { "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>", "[Q]uit buffer" },
  ["1"] = { "<cmd>BufferLineGoToBuffer 1<cr>", "[B]uffer [1]" },
  ["2"] = { "<cmd>BufferLineGoToBuffer 2<cr>", "[B]uffer [2]" },
  ["3"] = { "<cmd>BufferLineGoToBuffer 3<cr>", "[B]uffer [3]" },
  ["4"] = { "<cmd>BufferLineGoToBuffer 4<cr>", "[B]uffer [4]" },
  ["5"] = { "<cmd>BufferLineGoToBuffer 5<cr>", "[B]uffer [5]" },
  ["6"] = { "<cmd>BufferLineGoToBuffer 6<cr>", "[B]uffer [6]" },
  ["7"] = { "<cmd>BufferLineGoToBuffer 7<cr>", "[B]uffer [7]" },
  ["8"] = { "<cmd>BufferLineGoToBuffer 8<cr>", "[B]uffer [8]" },
  ["9"] = { "<cmd>BufferLineGoToBuffer 9<cr>", "[B]uffer [9]" },
  ["["] = { "<cmd>BufferLineCyclePrev<cr>", "[B]uffer [P]rev" },
  ["]"] = { "<cmd>BufferLineCycleNext<cr>", "[B]uffer [N]ext" },
  s = {
    name = "[S]ubstitute/[S]cratch",
    o = { require("substitute").operator, "[O]perator" },
    l = { require("substitute").line, "[L]ine" },
    e = { require("substitute").eol, "[E]nd of line" },
    i = { "<Plug>(scratch-insert-reuse)", "[I]nsert" },
    p = { "<cmd>ScratchPreview<CR>", "[P]review" },
    s = { "<cmd>Scratch<CR>", "[S]cratch" },
  },
})
vim.keymap.set("n", "<M-Del>", function()
  vim.cmd("Noice dismiss")
end)

vim.keymap.set("n", "<M-BS>", function()
  vim.cmd("Noice dismiss")
end)

wk.register({
  ["<C-s>"] = { require("substitute").operator, "[S]ubstitute [O]perator", mode = { "n" } },
})

wk.register({
  s = { require("substitute").visual, "[S]ubstitute Visual" },
  i = { "<Plug>(scratch-selection-reuse)<CR>", "[I]nsert" },
}, { prefix = "<leader>", mode = { "x" } })

wk.register(WK, { prefix = "<leader>" })
wk.register(WKN, {})
vim.api.nvim_set_keymap("n", "<C-p>", "<cmd>FzfLua files<cr>", { desc = "Find Files" })
vim.api.nvim_set_keymap("n", "U", "<C-r><CR>", { desc = "Redo" })
vim.api.nvim_set_keymap("n", "<M-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.api.nvim_set_keymap("n", "<M-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.api.nvim_set_keymap("i", "<M-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
vim.api.nvim_set_keymap("i", "<M-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.api.nvim_set_keymap("v", "<M-j>", "<Esc><cmd>m '>+1<CR>gv=gv", { desc = "Move line up" })
vim.api.nvim_set_keymap("v", "<M-k>", "<Esc><cmd>m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.api.nvim_set_keymap("i", "<esc>", "<C-[>", { desc = "Escape" })

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
