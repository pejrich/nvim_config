local M = {}

function M.setup()
  local plugin = require("cmp")
  local compare = require("cmp.config.compare")
  local mapping = plugin.mapping

  local bordered_window = plugin.config.window.bordered({
    winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
    col_offset = -3,
    side_padding = 0,
  })

  local max_buffer_size = 1024 * 1024 -- 1 Megabyte max

  local buffer_source = {
    name = "buffer",
    option = {
      get_bufnrs = function()
        local buf = vim.api.nvim_get_current_buf()
        local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
        if byte_size > max_buffer_size then
          return {}
        end
        return { buf }
      end,
      indexing_interval = 1000,
    },
  }
  plugin.setup({
    sorting = {
      priority_weight = 2,
      comparators = {
        function(a, b)
          if a.completion_item.detail == "Emmet Abbreviation" and a.completion_item.documentation == "<div>|</div>" then
            return true
          else
            return (a.kind == "luasnip" and b.kind ~= "luasnip")
          end
        end,
        compare.offset,
        compare.exact,
        -- compare.scopes,
        compare.score,
        compare.recently_used,
        compare.locality,
        compare.kind,
        -- compare.sort_text,
        compare.length,
        compare.order,
      },
    },
    sources = plugin.config.sources(
      vim.tbl_filter(function(component)
        return component ~= nil
      end, {
        { name = "luasnip", priority_weight = 120 },
        { name = "path", priority_weight = 110 },
        { name = "nvim_lsp", max_view_entries = 20, priority_weight = 100 },
        { name = "nvim_lsp_signature_help", priority_weight = 100 },
        { name = "nvim_lua", priority_weight = 90 },
        { name = "treesitter", priority_weight = 70 },
      }),
      {
        vim.tbl_deep_extend("force", buffer_source, {
          keyword_length = 5,
          max_view_entries = 5,
          option = {
            keyword_length = 5,
          },
          priority_weight = 70,
        }),
      }
    ),
    -- experimental = {
    --   native_menu = false,
    -- },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = mapping.preset.insert({
      ["<C-b>"] = mapping.scroll_docs(-4),
      ["<C-f>"] = mapping.scroll_docs(4),
      ["<C-Space>"] = mapping.complete(),
      ["<C-c>"] = mapping.complete(),
      ["<C-y>"] = mapping.abort(),
      ["<D-w>"] = mapping.abort(),
      ["<C-e>"] = mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    window = {
      completion = bordered_window,
      documentation = bordered_window,
    },
    performance = {
      throttle = 150,
      debounce = 150,
    },
    experimental = {
      ghost_text = true,
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        local kind = require("lspkind").cmp_format({
          mode = "symbol_text",
          menu = {
            luasnip = "Snip",
            nvim_lua = "Lua",
            nvim_lsp = "LSP",
            buffer = "Buf",
            path = "Path",
            crates = "Crates",
          },
          maxwidth = 50,
        })(entry, vim_item)
        local strings = vim.split(kind.kind, "%s", { trimempty = true })
        kind.kind = " " .. strings[1] .. " "
        if strings[2] then
          kind.menu = "    [" .. kind.menu .. ": " .. strings[2] .. "]"
        else
          kind.menu = "    [" .. kind.menu .. "]"
        end
        return kind
      end,
    },
  })

  -- autopairs :shake_hands:
  local autopairs = require("nvim-autopairs.completion.cmp")

  plugin.event:on("confirm_done", autopairs.on_confirm_done())
end

return M
