local M = {}
local kind_icons = {
  Text = "",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "  ",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "  ",
  TypeParameter = "  ",
}

function M.setup()
  local cmp = require("cmp")
  local lspkind = require("lspkind")
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local compare = require("cmp.config.compare")
  local mapping = cmp.mapping

  local bordered_window = cmp.config.window.bordered({
    winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
    col_offset = -3,
    side_padding = 0,
  })

  local buffer_source = {
    name = "buffer",
    option = {
      get_bufnrs = function()
        local buf = vim.api.nvim_get_current_buf()
        local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
        if byte_size > 1024 * 1024 then -- 1 Megabyte max
          return {}
        end
        return { buf }
      end,
    },
  }
  cmp.setup({
    preselect = cmp.PreselectMode.Item,
    keyword_length = 2,
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
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
    sources = cmp.config.sources(
      vim.tbl_filter(function(component)
        return component ~= nil
      end, {
        {
          name = "luasnip",
          group_index = 1,
          option = { use_show_condition = true },
          max_view_entries = 5,
          entry_filter = function()
            local context = require("cmp.config.context")
            return not context.in_treesitter_capture("string") and not context.in_syntax_group("String")
          end,
        },
        { name = "nvim_lsp", max_view_entries = 2, keyword_length = 4, group_index = 2 },
        { name = "path", group_index = 3, max_view_entries = 3 },
        { name = "nvim_lsp_signature_help", group_index = 4, max_view_entries = 5 },
        { name = "nvim_lua", group_index = 5, max_view_entries = 5 },
        { name = "treesitter", group_index = 6, keyword_length = 4, max_view_entries = 5 },
      }),
      {
        vim.tbl_deep_extend("force", buffer_source, {
          keyword_length = 2,
          max_view_entries = 5,
          option = {
            keyword_length = 5,
          },
        }),
      }
    ),
    -- experimental = {
    --   native_menu = false,
    -- },
    mapping = mapping.preset.insert({
      ["<C-b>"] = mapping.scroll_docs(-4),
      ["<C-f>"] = mapping.scroll_docs(4),
      ["<C-Space>"] = mapping.complete(),
      ["<C-c>"] = mapping.complete(),
      ["<C-y>"] = mapping.abort(),
      ["<D-w>"] = mapping.abort(),
      ["<S-CR>"] = mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<C-e>"] = mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    window = {
      completion = bordered_window,
      documentation = bordered_window,
    },
    view = {
      entries = {
        name = "custom",
        selection_order = "near_cursor",
        follow_cursor = true,
      },
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
        local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)

        local strings = vim.split(kind.kind, "%s", { trimempty = true })
        -- kind.kind = " " .. (strings[1] or "") .. " "
        kind.kind = " " .. (kind_icons[vim_item.kind] or strings[1] or "") .. " "
        kind.menu = "    (" .. (strings[2] or "") .. ")"

        return kind
      end,
    },
    -- formatting = {
    --   fields = { "kind", "abbr", "menu" },
    --   format = function(entry, vim_item)
    --     local kind = require("lspkind").cmp_format({
    --       mode = "symbol_text",
    --       menu = {
    --         luasnip = "Snip",
    --         nvim_lua = "Lua",
    --         nvim_lsp = "LSP",
    --         buffer = "Buf",
    --         path = "Path",
    --         crates = "Crates",
    --       },
    --       maxwidth = 50,
    --     })(entry, vim_item)
    --     local strings = vim.split(kind.kind, "%s", { trimempty = true })
    --     kind.kind = " " .. strings[1] .. " "
    --     if strings[2] then
    --       kind.menu = "    [" .. kind.menu .. ": " .. strings[2] .. "]"
    --     else
    --       kind.menu = "    [" .. kind.menu .. "]"
    --     end
    --     return kind
    --   end,
    -- },
  })

  local autopairs = require("nvim-autopairs.completion.cmp")

  cmp.event:on("confirm_done", autopairs.on_confirm_done())

  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path", max_view_entries = 5 },
    }, {
      {
        name = "cmdline",

        max_view_entries = 5,
        option = {

          max_view_entries = 5,
          ignore_cmds = { "Man", "!" },
        },
      },
    }),
  })
  print("CMP Setup")
end

return M
