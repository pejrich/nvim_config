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

  plugin.setup({
    sorting = {
      priority_weight = 2,
      comparators = {
        function(a, b)
          return (a.kind == "luasnip" and b.kind ~= "luasnip")
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
    sources = {
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "nvim_lua" },
      { name = "buffer" },
      { name = "path" },
      { name = "crates" },
    },
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
