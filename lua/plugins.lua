local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.cmd("let g:csv_nomap_sp = 1")
vim.cmd("let g:csv_nomap_space = 1")
vim.cmd("let g:csv_nomap_cr = 1")
vim.cmd("let g:csv_nomap_bs = 1")
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy")

local plugins = {
  -- stdlib
  {
    "nvim-lua/plenary.nvim",
  },
  {
    dir = "~/Documents/programming/nvim_plugins/scratch_pad.nvim",
    lazy = false,
    config = function()
      require("scratch_pad").setup()
    end,
  },
  {
    dir = "~/Documents/programming/nvim_plugins/mrs_doubtfire.nvim",
    config = function()
      require("mrs_doubtfire").setup({})
    end,
  },
  {
    dir = "~/Documents/programming/nvim_plugins/lopsided.nvim",
    config = function()
      require("lopsided").setup({})
    end,
  },
  {
    dir = "~/Documents/programming/nvim_plugins/chuck_and_grab.nvim",
    config = function()
      require("chuck_and_grab").setup()
    end,
  },

  -- theming
  {
    "rktjmp/lush.nvim",
    branch = "main",
    lazy = false,
  },
  {
    "tpope/vim-abolish",
  },

  -- keymaps
  {
    "folke/which-key.nvim",
    enable = false,
    config = require("plugins.which-key").setup,
  },

  -- welcome screen
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = require("plugins.alpha").setup,
  },

  -- essentials
  {
    "echasnovski/mini.trailspace",
    event = "BufEnter",
    config = require("plugins.mini-trailspace").setup,
  },
  {
    "mtth/scratch.vim",
    config = function()
      vim.cmd("let g:scratch_no_mappings = 1")
    end,
  },
  {
    -- "danilamihailov/beacon.nvim",
    "rainbowhxch/beacon.nvim",
    config = require("plugins.beacon").setup,
  },
  {
    "gbprod/substitute.nvim",
    branch = "main",
    config = function()
      require("substitute").setup({
        on_substitute = require("yanky.integration").substitute(),
      })

      require("which-key").add({
        { "P", require("substitute").operator, desc = "[S]ubstitue [O]perator" },
      })
    end,
  },
  {
    "folke/flash.nvim",
    -- dir = "/Users/peterrichards/Downloads/flash.nvim-main",
    -- dir = "/Users/peterrichards/Documents/programming/nvim_plugins/flash.nvim",
    branch = "main",
    event = "VeryLazy",
    config = require("plugins.flash").setup,
  },
  {
    "NMAC427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup({})
    end,
  },

  -- {
  --   "xiyaowong/virtcolumn.nvim",
  --   version = "*",
  --   event = "BufEnter",
  --   config = require("plugins.virtcolumn").setup,
  -- },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- commit = "86d2aa8",
    config = require("plugins.fzf-lua").setup,
  },
  { "junegunn/fzf", build = "./install --bin" },
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure({
        providers = {
          "treesitter",
          "regex",
        },
        delay = 200,
        large_file_cutoff = 2000,
      })
      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
  {
    "folke/trouble.nvim",
    branch = "main",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = require("plugins.trouble").setup,
  },
  {
    "gbprod/stay-in-place.nvim",
    branch = "main",
    config = function()
      require("stay-in-place").setup({})
    end,
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    config = function()
      vim.g.VM_show_warnings = 0
      -- vim.g.VM_maps = {
      --   ["I BS"] = "", -- disable backspace mapping
      -- }
    end,
    lazy = false,
  },
  -- {
  --   "tummetott/unimpaired.nvim",
  --   config = require("unimpaired").setup,
  -- },
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          rgb_fn = true, -- CSS rgb() and rgba() functions
          hsl_fn = true, -- CSS hsl() and hsla() functions
          css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Available modes for `mode`: foreground, background,  virtualtext
          -- Available methods are false / true / "normal" / "lsp" / "both"
          -- True is same as normal
          tailwind = true,
        },
      })
    end,
  },
  {
    "vidocqh/auto-indent.nvim",
    opts = {},
  },
  {
    "emmanueltouzery/elixir-extras.nvim",
    config = function()
      require("elixir-extras").setup_multiple_clause_gutter()
    end,
  },
  {
    "windwp/nvim-autopairs",
    branch = "master",
    event = "InsertEnter",
    config = require("plugins.autopairs").setup,
  },
  {
    "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
    version = "*",
  },
  {
    "tpope/vim-unimpaired",
  },

  {
    "echasnovski/mini.ai",
    branch = "main",
    event = "VeryLazy",
    config = require("plugins.miniai").setup,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require("plugins.harpoon").setup,
  },
  {
    "andymass/vim-matchup",
    branch = "master",
    config = function()
      vim.o.matchpairs = "(:),{:},[:]"
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  {
    "kylechui/nvim-surround",
    branch = "main",
    config = require("plugins.surround").setup,
  },

  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = require("plugins.aerial").setup,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = require("plugins.devicons").setup,
  },
  {
    "sitiom/nvim-numbertoggle",
    config = function() end,
  },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-neotest/nvim-nio" },
  {
    "karb94/neoscroll.nvim",
    config = require("plugins.neoscroll").setup,
  },
  {
    "smjonas/live-command.nvim",
    config = require("plugins.pcre").setup,
    -- live-command supports semantic versioning via tags
    -- tag = "1.*",
  },
  {
    "akinsho/bufferline.nvim",
    branch = "main",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = require("plugins.bufferline").setup,
  },
  -- {
  --   "romgrk/barbar.nvim",
  --   dependencies = {
  --     "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
  --     "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
  --   },
  --   config = require("plugins.barbar").setup,
  -- },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = require("plugins.persistence").setup,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    commit = "d9328ef903168b6f52385a751eb384ae7e906c6f",
    config = require("plugins.noice").setup,
    dependencies = {

      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufEnter",
    config = require("plugins.treesitter").setup,
    build = ":TSUpdate",
    lazy = false,
    priority = 999,
    cmd = { "TSUpdateSync" },
    dependencies = {
      "windwp/nvim-ts-autotag",
      "tpope/vim-endwise",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    event = "BufEnter",
  },
  {
    "pejrich/nvim-treesitter-context",
    branch = "master",
    opts = {
      -- max_lines = 5,
      filter = function(line, ext)
        local patterns = {
          ex = "^%s*%#",
          exs = "^%s*%#",
          lua = "^%s*%-%-",
        }
        local pattern = patterns[ext]
        return not pattern or line:find(pattern) == nil
      end,
      on_attach = function(buf)
        return vim.fn.wordcount().bytes < 1000000
      end,
    },
  },

  -- lsp
  {
    "williamboman/mason.nvim",
    branch = "main",
  },
  {
    "RRethy/nvim-treesitter-endwise",
    branch = "master",
  },
  {
    "windwp/nvim-ts-autotag",
    branch = "main",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
        filetypes = { "html", "xml", "eruby", "heex", "elixir", "embedded_template" },
      })
    end,
    lazy = true,
    event = "VeryLazy",
  },

  {
    "williamboman/mason-lspconfig.nvim",
    branch = "main",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = require("plugins.mason-lspconfig").setup,
  },

  {
    "neovim/nvim-lspconfig",
    branch = "master",
    event = "BufEnter",
    config = require("plugins.lsp.lspconfig").setup,
  },

  {
    "yamatsum/nvim-cursorline",
    branch = "main",
    config = require("plugins.cursorline").setup,
  },
  {
    "folke/lsp-colors.nvim",
    config = function()
      require("lsp-colors").setup({})
    end,
  },
  {
    "gbprod/yanky.nvim",
    branch = "main",
    config = require("plugins.yanky").setup,
  },
  {
    "glepnir/lspsaga.nvim",
    branch = "main", -- TODO: Go back to stable after the current version is released
    event = "BufEnter",
    config = require("plugins.lsp.lspsaga").setup,
  },

  -- {
  --   "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  --   branch = "main",
  --   event = "BufEnter",
  --   config = require("plugins.lsp.lsp-lines").setup,
  -- },

  {
    "mfussenegger/nvim-lint",
    event = "BufEnter",
    config = require("plugins.lint").setup,
  },
  {
    "stevearc/conform.nvim",
    event = "BufEnter",
    config = require("plugins.conform").setup,
  },

  -- {
  --   "folke/neodev.nvim",
  -- },
  -- {
  --   "tpope/vim-fugitive",
  -- },

  -- autocompletions
  {
    "hrsh7th/nvim-cmp",
    branch = "main",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",

      dependencies = {
        "L3MON4D3/LuaSnip",
        "ray-x/cmp-treesitter",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "onsails/lspkind.nvim",
      },
    },
    config = require("plugins.cmp").setup,
  },
  { "saadparwaiz1/cmp_luasnip" },

  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = "make install_jsregexp",
    config = require("plugins.luasnip").setup,
  },

  -- file tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      {
        "s1n7ax/nvim-window-picker",
        event = "VeryLazy",
        version = "2.*",
        config = require("plugins.window-picker").setup,
      },
    },
    config = require("plugins.neo-tree").setup,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },

  -- fuzzy finders
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
    },
    config = require("plugins.telescope").setup,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    branch = "master",
  },

  -- window management
  {
    "sindrets/winshift.nvim",
    event = "VimEnter",
    config = require("plugins.winshift").setup,
  },

  -- tab & status bar
  {
    "nvim-lualine/lualine.nvim",
    branch = "master",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = require("plugins.lualine").setup,
  },

  -- terminal
  {
    "akinsho/toggleterm.nvim",
    config = require("plugins.toggleterm").setup,
  },

  -- git
  {
    "kdheepak/lazygit.nvim",
  },

  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require("plugins.git.diffview").setup,
  },

  {
    "lewis6991/gitsigns.nvim",
    branch = "main",
    event = "BufEnter",
    config = require("plugins.git.gitsigns").setup,
  },

  -- search/replace
  {
    "nvim-pack/nvim-spectre",
    branch = "master",
    config = require("plugins.spectre").setup,
  },

  -- comments
  {
    "numToStr/Comment.nvim",
    event = "BufEnter",
    config = require("plugins.comment").setup,
  },

  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    build = require("plugins.markdown-preview").setup,
  },

  -- misc
  {
    "tenxsoydev/tabs-vs-spaces.nvim",
    event = "User ThemeApplied",
    config = require("plugins.tabs-vs-spaces").setup,
  },
  {
    "chrisbra/csv.vim",
  },
  {
    "AndrewRadev/switch.vim",
    config = function()
      vim.g.switch_mapping = "-"
      vim.keymap.set("n", "-", "<cmd>call switch#Switch()<cr>", { desc = "Switch" })
      vim.g.switch_custom_definitions = { { "assert", "refute" }, { "and", "or" }, { "==", "!=" }, { "if", "unless" } }
    end,
  },
  {
    dir = "~/Documents/programming/nvim_plugins/space.nvim",
    config = function() end,
  },
  {
    "rafcamlet/nvim-luapad",
    config = function()
      require("luapad").setup({})
    end,
  },
  {
    "editorconfig/editorconfig-vim",
  },
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = function()
      require("goto-preview").setup({
        width = 120, -- Width of the floating window
        height = 15, -- Height of the floating window
        border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }, -- Border characters of the floating window
        default_mappings = true, -- Bind default mappings
        debug = false, -- Print debug information
        opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
        resizing_mappings = false, -- Binds arrow keys to resizing the floating window.
        post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
        post_close_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
        references = { -- Configure the telescope UI for slowing the references cycling window.
          telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
        },
        -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
        focus_on_open = true, -- Focus the floating window when opening it.
        dismiss_on_move = true, -- Dismiss the floating window when moving the cursor.
        force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
        bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
        stack_floating_preview_windows = true, -- Whether to nest floating windows
        preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
        zindex = 1, -- Starting zindex for the stack of floating windows
      })
    end,
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    lazy = false,
    config = require("plugins.various-textobjs").setup,
  },
  {
    "chrisgrieser/nvim-spider",
    lazy = true,
    dependencies = {
      "theHamsta/nvim_rocks",
      build = "pip3 install --user hererocks && python3 -mhererocks . -j2.1.0-beta3 -r3.0.0 && cp nvim_rocks.lua lua",
      config = function()
        require("nvim_rocks").ensure_installed("luautf8")
      end,
    },
    config = function()
      require("spider").setup({
        skipInsignificantPunctuation = true,
        consistentOperatorPending = true, -- see "Consistent Operator-pending Mode" in the README
        subwordMovement = true,
        customPatterns = {}, -- check "Custom Movement Patterns" in the README for details
      })
    end,
  },
  {
    "andrewferrier/debugprint.nvim",
    dependencies = {
      "echasnovski/mini.nvim", -- Needed for :ToggleCommentDebugPrints (not needed for NeoVim 0.10+)
    },
    config = function()
      require("debugprint").setup({})
    end,
  },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<leader>?",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    config = function()
      require("bqf").setup({})
    end,
  },
  {
    "jremmen/vim-ripgrep",
  },
  {
    "stevearc/stickybuf.nvim",
    config = function()
      require("stickybuf").setup({
        -- This function is run on BufEnter to determine pinning should be activated
        get_auto_pin = function(bufnr)
          -- You can return "bufnr", "buftype", "filetype", or a custom function to set how the window will be pinned.
          -- You can instead return an table that will be passed in as "opts" to `stickybuf.pin`.
          -- The function below encompasses the default logic. Inspect the source to see what it does.
          return require("stickybuf").should_auto_pin(bufnr)
        end,
      })
    end,
  },
  {
    "stevearc/quicker.nvim",
    config = function()
      require("quicker").setup({})
    end,
  },
  {
    "farmergreg/vim-lastplace",
  },
  {
    "nvimtools/hydra.nvim",
    config = require("plugins.hydra").setup,
  },
  {
    "stevearc/profile.nvim",
    lazy = false,
  },
}
for _, i in ipairs(require("themes")) do
  table.insert(plugins, i)
end

local options = {
  defaults = {
    lazy = false,
    --   version = "*",
  },
  lockfile = "~/.config/nvim/lazy-lock.json",
}

lazy.setup(plugins, options)
