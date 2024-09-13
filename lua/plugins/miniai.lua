local M = {}
local l = {}
local next_next = function()
  local char = vim.fn.getcharstr()
  vim.cmd("exe 'norm vi" .. char .. "o\rllvi" .. char .. "'")
end
function M.setup()
  vim.keymap.set("o", "iN", next_next)
  vim.keymap.set("x", "iN", next_next)
  local ai = require("mini.ai")
  ai.setup({
    n_lines = 50000,
    mappings = {
      around_next = "an",
      inside_next = "in",
      around_last = "aL",
      inside_last = "iL",
    },
    custom_textobjects = {
      -- [K]ey = roughly anything to the left of `=` or `:`, until SOL, `{[(`, `,`
      k = {
        { "^%s*[^:=%s%{%[,]+%s*[:=]", "[%s%{%[,]+[^:=]-%s*[:=]", "^[^:=%[%{%(]+[:=]" },
        { "^[%s%{%[,]-()%s*()[^:=%{%[,]-()%s*()[:=]$", "^[^:=%[%{%(]-%s?[:=]$" },
      },
      -- k = { "[%s%{,]+()()[^:=]-()%s*()[:=]" },
      -- [V]alue = roughly anything to the right of `=` or `:`, up until `,`, `]})`
      v = { { "[%s%{]+[^:=]-%s*[:=]()%s*()[^%},]-()%s*()[%},]", "[%s%{]+[^:=]-%s*[:=]()%s*()[^%},]-()%s*()$" } },
      -- [x]ml/html attribute = `class="..."`, `data-state={...}`, etc.
      x = { { [[%s()[%w%-]+=%b{}()%s*]], [[%s()[%w%-]+=["'].-["']()%s*]] } },
      -- [c]lass in HTML
      c = {

        {
          '[%"]()()[^%s%"]*()[%s]()',
          '()[%s]()[^%s%"]*()()[%"]',
          '[%s]()()[^%s%"]*()[%s]()',
        },
      },
      -- single [C]har
      C = function(ai, id, opts)
        if ai == "i" then
          local col = vim.fn.col(".")
          local line = vim.fn.line(".")
          return {
            vis_mode = "v",
            from = { col = col, line = line },
            to = { col = col, line = line },
          }
        else
          local col = vim.fn.col(".")
          local line = vim.fn.line(".")
          local colmax = #vim.fn.getline(".")
          return {
            vis_mode = "v",
            from = { col = math.max(col - 1, 1), line = line },
            to = { col = math.min(col + 1, colmax), line = line },
          }
        end
      end,

      X = { "^[^=]*=()%s*().+()()$" },
      -- Substring
      S = {
        {
          "%W()()%w[%l%d]+()[_%- ]?()", -- camelCase or lowercase
          "%W()()%u[%u%d]+()[_%- ]?()", -- UPPER_CASE
          "%W()()%d+()[_%- ]?()", -- number

          "^()()%w[%l%d]+()[_%- ]?()", -- camelCase or lowercase
          "^()()%u[%u%d]+()[_%- ]?()", -- UPPER_CASE
          "^()()%d+()[_%- ]?()", -- number
        },
      },
      -- [e]lixir interpolation = #{...}
      e = { "#{().-()}" },
      -- [E]lixir interpolation = <%= ... %>
      -- [e]lixir is the more common interpolation. [E]lixir is the Heex only interpolation
      E = { "<%%=? ().-() %%>" },
      -- [T]erm = Roughly and value so `var`, `thing.attr`, `@attr`, `@some_var.some_attr`, typically delimited by ` `, `([{`, `}])`, `=`
      T = { { "^%s*[%w%.%_%-%@]+", "[^%w%.%_%-%@]+[%w%.%_%-%@]+" }, "^[^%w%.%_%-%@]*()%s*()[%w%.%_%-%@]+()%s*()[^%w%.%_%-%@]*$" },
      -- [l]ine charwise = similar to `yy` but without the newline, `i` excludes leading WS, `a` includes leading WS
      l = { "^()%s*().-()()\n" },
      -- m = { "^%%[A-Za-z0-9.]*{().-()}$" },
      -- [m]ap/struct = `%{...}`, or `%Some.Struct{...}`
      m = { "%%[A-Za-z0-9.]*%b{}", "^%%[A-Za-z0-9.]*{().-()}$" },
      o = ai.gen_spec.treesitter({
        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
      }, {}),
      ["?"] = function(...)
        print("? CALLED")
        local args = { ... }
        return require("plugins.miniai.lopsided").call(args[1])
      end,
      b = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
      M = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
      -- t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
      t = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
      ["%"] = nil,
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
