local lspconfig = require 'lspconfig'
local configs = require 'lspconfig.configs'
local elixirLsp = ''
local lexical_config = {
  filetypes = { 'elixir', 'eelixir', 'heex' },
  cmd = { 'ERL_OPTS="+MIscs 2048" /Users/peterrichards/Documents/programming/lexical/_build/dev/package/lexical/bin/start_lexical.sh' },
  settings = {},
}

local elixirls_config = {
  filetypes = { 'elixir', 'eelixir', 'heex' },
  cmd = { '/Users/peterrichards/elixirls' },
  settings = {},
}

local emmet_config = {
  default_config = {
    filetypes = {
      'html',
      'css',
      'scss',
      'javascript',
      'javascriptreact',
      'typescriptreact',
      'svelte',
      'elixir',
      'eelixir',
      'phoenix-heex',
      'heex',
    },
    cmd = { 'emmet-language-server', '--stdio' },
    root_dir = lspconfig.util.root_pattern '.git',
    init_options = {
      --- @type table<string, any> https://docs.emmet.io/customization/preferences/
      preferences = {},
      --- @type "always" | "never" defaults to `"always"`
      showexpandedabbreviation = 'always',
      --- @type boolean defaults to `true`
      showabbreviationsuggestions = true,
      --- @type boolean defaults to `false`
      showsuggestionsassnippets = false,
      --- @type table<string, any> https://docs.emmet.io/customization/syntax-profiles/
      syntaxprofiles = {},
      --- @type table<string, string> https://docs.emmet.io/customization/snippets/#variables
      variables = {},
      --- @type string[]
      excludelanguages = {},
    },
  },
}

local M = {
  {
    'neovim/nvim-lspconfig',
    -- lazy = true,
    config = function()
      local lspconfig = require 'lspconfig'
      local configs = require 'lspconfig.configs'

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      lspconfig.tsserver.setup {}
      lspconfig.emmet_ls.setup {
        -- on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {
          'css',
          'eruby',
          'html',
          'javascript',
          'javascriptreact',
          'less',
          'sass',
          'scss',
          'svelte',
          'pug',
          'typescriptreact',
          'vue',
          'elixir',
          'eelixir',
          'heex',
          'phoenix-heex',
        },
        init_options = {
          html = {
            options = {
              -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
              ['bem.enabled'] = true,
            },
          },
        },
      }
      if not configs.emmet_language_server then
        configs.emmet_language_server = emmet_config
      end
      if not configs.elixirls then
        configs.elixirls = {
          default_config = {
            filetypes = elixirls_config.filetypes,
            cmd = elixirls_config.cmd,
            settings = elixirls_config.settings,
            root_dir = function(fname)
              return lspconfig.util.root_pattern('mix.exs', '.git')(fname) or vim.loop.os_homedir()
            end,
          },
        }
      end
      lspconfig.elixirls.setup {}
      if elixirLsp == 'lexical' then
        if not configs.lexical then
          configs.lexical = {
            default_config = {
              filetypes = lexical_config.filetypes,
              cmd = lexical_config.cmd,
              root_dir = function(fname)
                return lspconfig.util.root_pattern('mix.exs', '.git')(fname) or vim.loop.os_homedir()
              end,
              -- optional settings
              settings = lexical_config.settings,
            },
          }
        end
        lspconfig.lexical.setup {
          -- optional config
          -- on_attach = custom_attach,
          -- keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts),
          keymap('n', '<leader>li', '<cmd>LspInfo<cr>', opts),
        }
      end
      lspconfig.lua_ls.setup {}
      local keymap = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }
      lspconfig.emmet_language_server.setup {
        filetypes = {
          'css',
          'eruby',
          'html',
          'javascript',
          'javascriptreact',
          'less',
          'sass',
          'scss',
          'pug',
          'typescriptreact',
          'elixir',
          'eelixir',
          'heex',
          'phoenix-heex',
        },
        -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
        -- **Note:** only the options listed in the table are supported.
        init_options = {
          ---@type table<string, string>
          includeLanguages = {},
          --- @type string[]
          excludeLanguages = {},
          --- @type string[]
          extensionsPath = {},
          --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
          preferences = {},
          --- @type boolean Defaults to `true`
          showAbbreviationSuggestions = true,
          --- @type "always" | "never" Defaults to `"always"`
          showExpandedAbbreviation = 'always',
          --- @type boolean Defaults to `false`
          showSuggestionsAsSnippets = false,
          --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
          syntaxProfiles = {},
          --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
          variables = {},
        },
      }

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end,
  },
  {
    'hrsh7th/cmp-nvim-lsp',
    config = function() end,
  },
}

return { M }
