local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

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
    version = "*",
  },

  -- theming
  {
    "rktjmp/lush.nvim",
    branch = "main",
    lazy = false,
  },
  {
    "projekt0n/github-nvim-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        -- ...
      })

      vim.cmd("colorscheme github_dark")
    end,
  },

  -- keymaps
  {
    "folke/which-key.nvim",
    version = "*",
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
    version = "*",
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
    "danilamihailov/beacon.nvim",
    config = function()
      vim.cmd("let g:beacon_size = 15")
    end,
  },
  {
    "gbprod/substitute.nvim",
    config = function()
      require("substitute").setup({
        on_substitute = require("yanky.integration").substitute(),
      })

      K.merge_wk_normal({
        P = { require("substitute").operator, "[S]ubstitue [O]perator", mode = { "n" } },
      })
    end,
  },
  {
    "folke/flash.nvim",
    -- dir = "/Users/peterrichards/Downloads/flash.nvim-main",
    -- dir = "/Users/peterrichards/Documents/programming/nvim_plugins/flash.nvim",
    version = "*",
    event = "VeryLazy",
    config = require("plugins.flash").setup,
  },

  {
    "xiyaowong/virtcolumn.nvim",
    version = "*",
    event = "BufEnter",
    config = require("plugins.virtcolumn").setup,
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- commit = "86d2aa8",
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({
        "telescope",
        previewers = { builtin = { syntax = true, syntax_limit_b = 0 } },
        files = { cmd = "rg --files --hidden", multiprocess = true, file_icons = true, git_icons = true, color_icons = true },
        grep = { multiprocess = true, file_icons = true, git_icons = true, color_icons = true },
        buffers = {
          file_icons = true, -- show file icons?
          color_icons = true, -- colorize file|git icons
          sort_lastused = true,
        },
      })
    end,
  },
  { "junegunn/fzf", build = "./install --bin" },
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").setup({
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
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = require("plugins.trouble").setup,
  },
  {
    "gbprod/stay-in-place.nvim",
    config = function()
      require("stay-in-place").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    config = function() end,
    lazy = false,
  },
  {
    "tummetott/unimpaired.nvim",
    config = function()
      require("unimpaired").setup()
    end,
  },
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  --   config = function()
  --     vim.g.VM_default_mappings = 0
  --     vim.g.VM_maps = {
  --       ["Find Under"] = "<C-x>",
  --       ["Find Subword Under"] = "<C-x>",
  --     }
  --     vim.keymap.set("n", "<C-x>", "<Plug>(VM-Find-Under)")
  --     -- Tried these as well but they do not work.
  --     -- vim.g.VM_maps['Find Subword Under'] = "<C-x>"
  --     -- vim.g.VM_maps["Select Cursor Down"] = '<M-u>'
  --     -- vim.g.VM_maps["Select Cursor Up"]   = '<M-d>'
  --   end,
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
  -- {
  --   "elixir-tools/elixir-tools.nvim",
  --   version = "*",
  --   event = { "BufReadPre", "BufNewFile" },
  --   config = require("plugins.lsp.servers.elixir").setup,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  -- },
  -- {
  --   "elixir-tools/elixir-tools.nvim",
  --   version = "*",
  --   -- dev = true,
  --   event = { "BufReadPre", "BufNewFile" },
  --   -- config = function()
  --   --   local elixir = require("elixir")
  --   --   local nextls_opts
  --   --   if vim.env.NEXTLS_LOCAL == "1" then
  --   --     nextls_opts = {
  --   --       enable = true,
  --   --       port = 9000,
  --   --       spitfire = true,
  --   --       init_options = {
  --   --         experimental = {
  --   --           completions = {
  --   --             enable = true,
  --   --           },
  --   --         },
  --   --       },
  --   --     }
  --   --   else
  --   --     nextls_opts = {
  --   --       enable = true,
  --   --       spitfire = true,
  --   --       init_options = {
  --   --         experimental = {
  --   --           completions = {
  --   --             enable = true,
  --   --           },
  --   --         },
  --   --       },
  --   --     }
  --   --   end
  --   --
  --   --   elixir.setup({
  --   --     nextls = nextls_opts,
  --   --     credo = { enable = false },
  --   --     elixirls = { enable = false },
  --   --   })
  --   -- end,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "mhanberg/workspace-folders.nvim",
  --   },
  -- },
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
    version = "*",
    event = "InsertEnter",
    config = require("plugins.autopairs").setup,
  },
  {
    "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
    version = "*",
  },

  {
    "echasnovski/mini.ai",

    version = "*",
    event = "VeryLazy",
    config = require("plugins.miniai").setup,
  },
  { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]parenthen
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 50000 })
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require("plugins.harpoon").setup,
  },
  {
    "andymass/vim-matchup",
    event = { "BufReadPost" },
    version = "*",
    setup = function()
      vim.o.matchpairs = "(:),{:},[:]"
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
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
    version = "*",
    config = require("plugins.devicons").setup,
  },
  {
    "sitiom/nvim-numbertoggle",
    version = "*",
    config = function() end,
  },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-neotest/nvim-nio" },
  {
    "karb94/neoscroll.nvim",
    version = "*",
    config = require("plugins.neoscroll").setup,
  },
  {
    "smjonas/live-command.nvim",
    version = "*",
    config = require("plugins.pcre").setup,
    -- live-command supports semantic versioning via tags
    -- tag = "1.*",
  },
  {
    "akinsho/bufferline.nvim",
    -- version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = require("plugins.bufferline").setup,
  },

  -- {
  --     "shortcuts/no-neck-pain.nvim",
  --     version = "*",
  --     config = require("plugins.no-neck-pain").setup,
  -- },

  -- {
  --     "folke/zen-mode.nvim",
  --     version = "*",
  --     config = require("plugins.zen-mode").setup,
  -- },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = require("plugins.persistence").setup,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
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
    version = "*",
    event = "BufEnter",
    config = require("plugins.treesitter").setup,
    build = ":TSUpdate",
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    version = "*",
    event = "BufEnter",
  },
  {
    "pejrich/nvim-treesitter-context",
    -- version = "*",
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
    },
  },

  {
    "nkrkv/nvim-treesitter-rescript",
    version = "*",
  },

  -- lsp
  {
    "williamboman/mason.nvim",
    version = "*",
  },
  {
    "RRethy/nvim-treesitter-endwise",
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup({
        enable = true,
        enable_rename = true,
        enable_close = true,
        filetypes = { "html", "xml", "heex", "elixir" },
      })
    end,
    lazy = true,
    event = "VeryLazy",
  },

  {
    "williamboman/mason-lspconfig.nvim",
    version = "*",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Brief Aside: **What is LSP?**
      --
      -- LSP is an acronym you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, :help lsp-vs-treesitter

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- NOTE: Remember that lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself
          -- many times.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-T>.
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

          -- Find references for the word under your cursor.
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

          -- Fuzzy find all the symbols in your current workspace
          --  Similar to document symbols, except searches over your whole project.
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

          -- Rename the variable under your cursor
          --  Most Language Servers support renaming across files, etc.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP Specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --

        lua_ls = {
          -- cmd = {...},
          -- filetypes { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  "${3rd}/luv/library",
                  unpack(vim.api.nvim_get_runtime_file("", true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        elixirls = {},
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu
      require("mason").setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format lua code
        "elixirls",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            require("lspconfig")[server_name].setup({
              cmd = server.cmd,
              settings = server.settings,
              filetypes = server.filetypes,
              -- This handles overriding only values explicitly passed
              -- by the server configuration above. Useful when disabling
              -- certain features of an LSP (for example, turning off formatting for tsserver)
              capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {}),
            })
          end,
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    branch = "master",
    event = "BufEnter",
    config = require("plugins.lsp.lspconfig").setup,
  },

  {
    "yamatsum/nvim-cursorline",
    version = "*",
    config = require("plugins.cursorline").setup,
  },
  {
    "gbprod/yanky.nvim",
    version = "*",
    config = require("plugins.yanky").setup,
    keys = {
      {
        "<C-p>",
        function()
          if require("yanky").can_cycle() == true then
            require("yanky").cycle(1)
          else
            require("substitute").operator()
          end
        end,
      },
      {
        "<C-S-p>",
        function()
          require("yanky").cycle(-1)
        end,
      },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },

      {
        "<A-r>",
        "<cmd>Telescope yank_history theme=cursor previewer=false<cr>",
        desc = "[Y]ank History",
        mode = { "i", "n", "x" },
      },
    },
  },
  {
    "glepnir/lspsaga.nvim",
    -- branch = "main", -- TODO: Go back to stable after the current version is released
    event = "BufEnter",
    config = require("plugins.lsp.lspsaga").setup,
  },

  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    branch = "main",
    event = "BufEnter",
    config = require("plugins.lsp.lsp-lines").setup,
  },

  {
    "mfussenegger/nvim-lint",
    version = "*",
    event = "BufEnter",
    config = require("plugins.lint").setup,
  },

  {
    "stevearc/conform.nvim",
    version = "*",
    event = "BufEnter",
    config = require("plugins.conform").setup,
  },

  {
    "folke/neodev.nvim",
    version = "*",
  },

  -- autocompletions
  {
    "hrsh7th/nvim-cmp",
    version = "*",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "onsails/lspkind.nvim",
    },
    config = require("plugins.cmp").setup,
  },
  { "saadparwaiz1/cmp_luasnip" },

  {
    "L3MON4D3/LuaSnip",
    version = "*",
    event = "InsertEnter",
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

  -- fuzzy finders
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { -- If encountering errors, see telescope-fzf-native README for install instructions
        "nvim-telescope/telescope-fzf-native.nvim",

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = "make",

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        -- cond = function()
        --   return vim.fn.executable 'make' == 1
        -- end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
    },
    config = require("plugins.telescope").setup,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    version = "*",
  },

  -- window management
  {
    "sindrets/winshift.nvim",
    version = "*",
    event = "VimEnter",
    config = require("plugins.winshift").setup,
  },

  {
    "rebelot/kanagawa.nvim",
    version = "*",
    config = function()
      vim.opt.termguicolors = true
      vim.cmd("colorscheme kanagawa")
    end,
  },

  -- tab & status bar
  {
    "nvim-lualine/lualine.nvim",
    version = "*",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = require("plugins.lualine").setup,
  },

  -- terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = require("plugins.toggleterm").setup,
  },

  -- git
  {
    "kdheepak/lazygit.nvim",
    version = "*",
  },

  -- {
  --   "SuperBo/fugit2.nvim",
  --   version = "*",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --     "nvim-lua/plenary.nvim",
  --     {
  --       "chrisgrieser/nvim-tinygit",
  --       dependencies = { "stevearc/dressing.nvim" },
  --     },
  --   },
  --   cmd = { "Fugit2", "Fugit2Graph" },
  --   config = true,
  -- },
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
    version = "*",
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
    version = "*",
    config = require("plugins.spectre").setup,
  },

  -- comments
  {
    "numToStr/Comment.nvim",
    version = "*",
    event = "BufEnter",
    config = require("plugins.comment").setup,
  },

  {
    "folke/todo-comments.nvim",
    version = "*",
    event = "BufEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require("plugins.todo-comments").setup,
  },

  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    version = "*",
    build = require("plugins.markdown-preview").setup,
  },

  {
    "mzlogin/vim-markdown-toc",
    version = "*",
  },

  -- misc
  {
    "tenxsoydev/tabs-vs-spaces.nvim",
    version = "*",
    event = "User ThemeApplied",
    config = require("plugins.tabs-vs-spaces").setup,
  },
}

local options = {
  defaults = {
    lazy = false,
    version = "*",
  },
  lockfile = "~/.config/nvim/lazy-lock.json",
}

lazy.setup(plugins, options)
