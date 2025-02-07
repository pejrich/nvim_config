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
  local cmp_buffer = require("cmp_buffer")
  local lspkind = require("lspkind")
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
        print("CALLED")
        local buf = vim.api.nvim_get_current_buf()
        local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
        if byte_size > 1024 * 1024 then -- 1 Megabyte max
          print("toobig")
          return {}
        end
        print("nottoobig")
        return { buf }
      end,
    },
  }
  cmp.setup({
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
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
            return a.kind == "luasnip"
            -- return (a.kind ~= "luasnip" and b.kind == "luasnip")
          end
        end,

        compare.offset,
        compare.exact,
        -- compare.scopes,
        compare.score,
        compare.recently_used,
        compare.locality,
        compare.kind,

        function(...)
          return cmp_buffer:compare_locality(...)
        end,
        -- compare.sort_text,
        compare.length,
        compare.order,
      },
    },
    sources = cmp.config.sources(vim.tbl_filter(function(component)
      return component ~= nil
    end, {
      {
        name = "luasnip",
        group_index = 1,
        option = {
          use_show_condition = true,
          get_bufnrs = M.get_bufnrs,
        },
        max_view_entries = 5,
        entry_filter = function()
          local context = require("cmp.config.context")
          return not context.in_treesitter_capture("string") and not context.in_syntax_group("String")
        end,
      },
      {
        name = "buffer",

        option = {
          indexing_interval = 500,
          indexing_batch_size = 3000,
          max_indexed_line_length = 1024 * 10,
          keyword_length = 3,
          max_view_entries = 5,
          get_bufnrs = M.get_bufnrs,
          -- get_bufnrs = function()
          --   print("CALLED")
          --   local buf = vim.api.nvim_get_current_buf()
          --   local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
          --   if byte_size > 1024 * 1024 then -- 1 Megabyte max
          --     print("toobig")
          --     return {}
          --   end
          --   print("nottoobig")
          --   return { buf }
          -- end,
        },
      },
      {
        name = "nvim_lsp",
        max_view_entries = 2,
        keyword_length = 4,
        group_index = 2,
        option = {
          get_bufnrs = M.get_bufnrs,
        },
      },
      { name = "path", group_index = 3, max_view_entries = 3, option = { get_bufnrs = M.get_bufnrs } },
      { name = "nvim_lsp_signature_help", group_index = 4, max_view_entries = 5, option = { get_bufnrs = M.get_bufnrs } },
      { name = "nvim_lua", group_index = 5, max_view_entries = 5, option = { get_bufnrs = M.get_bufnrs } },
      -- { name = "treesitter", group_index = 6, keyword_length = 4, max_view_entries = 5 },
    })),
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
      ["<S-CR>"] = mapping(function()
        vim.cmd("norm! m9")
        mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })()
        local curpos = require("utils").cur_pos()
        vim.api.nvim_buf_set_mark(0, "9", curpos[1], curpos[2], {})
      end),
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

  -- local autopairs = require("nvim-autopairs.completion.cmp")

  -- cmp.event:on("confirm_done", autopairs.on_confirm_done())

  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer", max_view_entries = 5, option = { get_bufnrs = M.get_bufnrs } },
    },
  })
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path", max_view_entries = 5, option = { get_bufnrs = M.get_bufnrs } },
    }, {
      {
        name = "cmdline",

        max_view_entries = 5,
        option = {
          get_bufnrs = M.get_bufnrs,

          max_view_entries = 5,
          ignore_cmds = { "Man", "!" },
        },
      },
    }),
  })
end

function M.get_bufnrs()
  local buf = vim.api.nvim_get_current_buf()
  local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
  if byte_size > 1024 * 1024 then -- 1 Megabyte max
    return {}
  end
  return { buf }
end
return M
