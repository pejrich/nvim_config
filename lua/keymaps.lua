-- Core
vim.cmd([==[
for chars in [["(", ","], [",", ")"]]
	execute "xnoremap i" . chars[0] . chars[1] . " :<C-u>execute 'normal! ' . v:count1 . 'T" . chars[0] . "v' . (v:count1 + (v:count1 - 1)) . 't" . chars[1] . "'<CR>"
	execute "onoremap i" . chars[0] . chars[1] . " :normal vi" . chars[0] . chars[1] . "<CR>"
	execute "xnoremap a" . chars[0] . chars[1] . " :<C-u>execute 'normal! ' . v:count1 . 'F" . chars[0] . "v' . (v:count1 + (v:count1 - 1)) . 'f" . chars[1] . "'<CR>"
	execute "onoremap a" . chars[0] . chars[1] . " :normal va" . chars[0] . chars[1] . "<CR>"
endfor
]==])

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
    name = "[E]lixr",
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
  ["!"] = {
    name = "Misc",
    p = {
      f = { F.start_flame_profile, "Start [P]rofile [F]lame" },
      s = { F.start_profile, "Start [P]rofile" },
      e = { F.stop_profile, "Profile [E]nd" },
    },
  },
  b = {
    name = "[B]uffer",
    s = { "<cmd>BufferLinePick<cr>", "[B]uffer [S]elect" },
    c = { "<cmd>BufferLinePickClose<cr>", "[B]uffer Select to [C]lose" },
    n = { "<cmd>BufferLineCycleNext<cr>", "[B]uffer [N]ext" },
    p = { "<cmd>BufferLineCyclePrev<cr>", "[B]uffer [P]rev" },
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
  c = {
    j = {
      function()
        local int = math.max(vim.v.count, 1)
        vim.cmd("m .+" .. int .. "<CR>==")
        vim.cmd("norm! " .. vim.v.count .. "k")
      end,
      "[C]huck Up",
    },
    k = {
      function()
        local int = (-1 * math.max(vim.v.count, 1)) - 1
        vim.cmd("m ." .. int .. "<CR>==")
        vim.cmd("norm! " .. vim.v.count .. "j")
      end,
      "[C]huck Down",
    },
    K = {
      function()
        local int = math.max(vim.v.count, 1)
        vim.cmd("norm! " .. vim.v.count .. "k")
        vim.cmd("m .+" .. int .. "<CR>==")
        -- vim.cmd("norm! " .. vim.v.count .. "k")
        -- vim.cmd("m ." .. int .. "<CR>==")
        -- vim.cmd("norm! " .. vim.v.count .. "j")
      end,
      "Grap Up",
    },
    J = {
      function()
        local int = (-1 * math.max(vim.v.count, 1)) - 1
        vim.cmd("norm! " .. vim.v.count .. "j")
        vim.cmd("m ." .. int .. "<CR>==")
        -- vim.cmd("norm! " .. vim.v.count .. "k")
      end,
      "Grab Down",
    },
  },
  -- vim.api.nvim_set_keymap('n', '<leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>', { desc = 'Close buffer' })
})

wk.register({
  ["<C-s>"] = { require("substitute").operator, "[S]ubstitute [O]perator", mode = { "n" } },
})

wk.register({
  s = { require("substitute").visual, "[S]ubstitute Visual" },
  i = { "<Plug>(scratch-selection-reuse)<CR>", "[I]nsert" },
}, { prefix = "<leader>", mode = { "x" } })

--      vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
-- vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
-- vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
-- vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })
wk.register(WK, { prefix = "<leader>" })
wk.register(WKN, {})
vim.api.nvim_set_keymap("n", "<A-p>", "<cmd>FzfLua files<cr>", { desc = "Find Files" })
vim.api.nvim_set_keymap("n", "U", "<C-r><CR>", { desc = "Redo" })
vim.api.nvim_set_keymap("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.api.nvim_set_keymap("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.api.nvim_set_keymap("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
vim.api.nvim_set_keymap("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.api.nvim_set_keymap("i", "<esc>", "<C-[>", { desc = "Escape" })

vim.cmd([[
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
]])
