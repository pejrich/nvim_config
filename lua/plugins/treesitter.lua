local M = {}

function M.setup()
  local install = require("nvim-treesitter.install")
  local plugin = require("nvim-treesitter.configs")

  install.compilers = { "gcc" }

  plugin.setup({
    auto_install = true,
    ignore_install = {},

    sync_install = false,

    matchup = {
      enable = true,
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      use_languagetree = false,
      disable = function(lang, bufnr)
        local buf_name = vim.api.nvim_buf_get_name(bufnr)
        local file_size = vim.api.nvim_call_function("getfsize", { buf_name })
        return file_size > 256 * 1024
      end,
    },
    endwise = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = false, -- set to `false` to disable one of the mappings
        node_incremental = "v",
        -- scope_incremental = 'grc',
        node_decremental = "V",
      },
    },
    autotag = {
      enable = true,
      filetypes = { "html", "xml", "eruby", "heex", "elixir", "embedded_template" },
    },
    ensure_installed = {
      "elixir",
      "heex",
      "embedded_template",
      "html",
      "javascript",
      "lua",
      "toml",
      "typescript",
      "css",
      "json",
      "markdown",
      "markdown_inline",
      "regex",
      "rust",
      "yaml",
      "csv",
      "tsv",
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          -- ["af"] = "@function.outer",
          -- ["if"] = "@function.inner",
          -- ["ar"] = "@return.outer",
          -- ["ir"] = "@return.inner",
          -- ["ab"] = "@block.outer",
          -- ["ib"] = "@block.inner",
          -- ["ae"] = "@class.outer",
          -- ["ie"] = "@class.inner",
          -- ["ac"] = "@comment.outer",
          -- ["ic"] = "@comment.inner",
          -- ["ap"] = "@parameter.outer",
          -- ["ip"] = "@parameter.inner",
          -- ["am"] = "@conditional.outer",
          -- ["im"] = "@conditional.inner",
          -- ["aa"] = "@assignment.outer",
          -- ["ian"] = "@assignment.lhs",
          -- ["iav"] = "@assignment.rhs",
          -- ["as"] = "@statement.outer",
          -- ["is"] = "@statement.inner",
          -- ["al"] = "@loop.outer",
          -- ["il"] = "@loop.inner",
          -- ["ax"] = "@call.outer",
          -- ["ix"] = "@call.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        lookahead = true,
        goto_next = {
          -- ["]f"] = "@function.outer",
          -- ["]r"] = "@return.outer",
          -- ["]b"] = "@block.outer",
          -- ["]e"] = "@class.outer",
          -- ["]c"] = "@comment.outer",
          -- ["]p"] = "@parameter.outer",
          -- ["]m"] = "@conditional.outer",
          -- ["]an"] = "@assignment.lhs",
          -- ["]av"] = "@assignment.rhs",
          -- ["]s"] = "@statement.outer",
          -- ["]l"] = "@loop.outer",
          -- ["]xa"] = "@call.outer",
          -- ["]xi"] = "@call.inner",
        },
        goto_previous = {
          -- ["[f"] = "@function.outer",
          -- ["[r"] = "@return.outer",
          -- ["[b"] = "@block.outer",
          -- ["[e"] = "@class.outer",
          -- ["[c"] = "@comment.outer",
          -- ["[p"] = "@parameter.outer",
          -- ["[m"] = "@conditional.outer",
          -- ["[an"] = "@assignment.lhs",
          -- ["[av"] = "@assignment.rhs",
          -- ["[s"] = "@statement.outer",
          -- ["[l"] = "@loop.outer",
          -- ["[xa"] = "@call.outer",
          -- ["[xi"] = "@call.inner",
        },
      },
      swap = {
        enable = true,
        -- swap_next = {
        --     ["<Leader>a"] = "@parameter.inner",
        -- },
        -- swap_previous = {
        --     ["<Leader>A"] = "@parameter.inner",
        -- },
      },
    },
  })

  local injections = [[((sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content)
 (#eq? @_sigil_name "H")
 (#set! injection.language "heex")
 (#set! injection.combined))
]]
  require("vim.treesitter.query").set("elixir", "injections", injections)
end

function M.keymaps() end

return M
