local M = {}
function M.setup()
  local ai = require("mini.ai")
  ai.setup({
    n_lines = 50000,
    mappings = {
      around_next = "aN",
      inside_next = "iN",
      around_last = "aL",
      inside_last = "iL",
    },
    custom_textobjects = {
      e = { "#{().-()}" },
      E = { "<%%= ().-() %%>" },
      l = { "^()%s+().-()()\n" },
      o = ai.gen_spec.treesitter({
        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
      }, {}),
      b = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
      m = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
      -- t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
      t = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
    },
  })
  -- register all text objects with which-key
  ---@type table<string, string|table>
  local i = {
    [" "] = "Whitespace",
    ['"'] = 'Balanced "',
    ["'"] = "Balanced '",
    ["`"] = "Balanced `",
    ["("] = "Balanced (",
    [")"] = "Balanced ) including white-space",
    [">"] = "Balanced > including white-space",
    ["<lt>"] = "Balanced <",
    ["]"] = "Balanced ] including white-space",
    ["["] = "Balanced [",
    ["}"] = "Balanced } including white-space",
    ["{"] = "Balanced {",
    ["?"] = "User Prompt",
    _ = "Underscore",
    a = "Argument",
    b = "Balanced ), ], }",
    m = "Module/Class",
    f = "Function Call",
    o = "Block, conditional, loop",
    q = "Quote `, \", '",
    t = "Tag",
  }
  local a = vim.deepcopy(i)
  for k, v in pairs(a) do
    a[k] = v:gsub(" including.*", "")
  end

  local ic = vim.deepcopy(i)
  local ac = vim.deepcopy(a)
  local i2 = {}
  local a2 = {}
  for k, v in pairs(i) do
    table.insert(i2, { "i" .. k, group = v, mode = { "o", "x" } })
  end

  for k, v in pairs(a) do
    table.insert(a2, { "a" .. k, group = v, mode = { "o", "x" } })
  end
  for key, name in pairs({ n = "Next", l = "Last" }) do
    for k, v in pairs(ic) do
      table.insert(i2, { "i" .. key .. k, group = "Inside " .. name .. " textobject", mode = { "o", "x" } })
    end
    for k, v in pairs(ac) do
      table.insert(a2, { "a" .. key .. k, group = "Around " .. name .. " textobject", mode = { "o", "x" } })
    end
    -- i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
    -- a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
  end
  require("which-key").add({ a2 })
  require("which-key").add({ i2 })
end

return M
