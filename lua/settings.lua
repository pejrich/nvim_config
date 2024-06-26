local g = vim.g
local opt = vim.opt
-- replace default search with search by regex
vim.api.nvim_set_keymap("n", "/", "/\\v", { noremap = true })
vim.api.nvim_set_keymap("v", "/", "/\\v", { noremap = true })
-- copy file path to `unnamedplus` clipboard

-- vim.cmd("!echo -n %:p | pbcopy")
vim.api.nvim_set_keymap("n", "cp", [[:let @+ = expand("%:p")<CR>]], { noremap = true, desc = "Copy file path to `unnamedplus` clipboard" })
-- command-mode completion
vim.api.wildmenu = true
-- Wildmenu ignores case
vim.api.wildignorecase = true
g.mapleader = " "
g.maplocalleader = " "
vim.cmd("set nrformats+=unsigned")
-- vim.cmd "set foldmethod=expr"
-- vim.cmd "set foldexpr=nvim_treesitter#foldexpr()"
-- vim.cmd 'autocmd BufWinEnter, BufReadPost, FileReadPost * normal zR'
-- vim.cmd "set foldlevesstart=1"
-- [[ Setting options ]]
-- See `:help opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
-- opt.relativenumber = true
opt.tabstop = 2
opt.expandtab = true
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.foldlevelstart = 99
opt.foldmethod = "manual"
-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = "a"

-- Don't show the mode, since it's already in status line
opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard = "unnamedplus"

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = "yes"

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  precedes = "←",
  extends = "→",
}

opt.iskeyword:append("-")
-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true
opt.guicursor = { "n-v-c-sm:hor10-iCursor-blinkwait300-blinkon200-blinkoff150,i-ci-ve:ver25,r-cr-o:hor20" }

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

opt.termguicolors = true

opt.number = true

opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"

opt.list = true

opt.fillchars = { eob = " ", diff = "" }

opt.splitright = true
opt.splitbelow = true
opt.equalalways = true

-- opt.showtabgline = 1

opt.wrap = false

opt.whichwrap:append({
  ["<"] = true,
  [">"] = true,
  ["["] = true,
  ["]"] = true,
  h = true,
  l = true,
})

opt.autoread = true
opt.autowrite = true
opt.autowriteall = true

-- opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- g.loadednetrw = 1
-- g.loaded_netrwPlugin = 1
