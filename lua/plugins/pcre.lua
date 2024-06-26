local function parse_sub_exp(s)
  local a, b, c = s:gsub("/", "/\1"):gsub("\\(.)", "\2%1"):gsub("%f[/\2]/", "\0"):gsub("[\1\2]", ""):match("%z(%Z*)%z(%Z*)%z(%Z*)")
  if a and b and c then
    return "s/" .. a .. "/" .. b .. "/" .. c
  end
  local a, b = s:gsub("/", "/\1"):gsub("\\(.)", "\2%1"):gsub("%f[/\2]/", "\0"):gsub("[\1\2]", ""):match("%z(%Z*)%z(%Z*)")
  if a and b then
    return "s/" .. a .. "/" .. b .. "/"
  end
  local a = s:gsub("/", "/\1"):gsub("\\(.)", "\2%1"):gsub("%f[/\2]/", "\0"):gsub("[\1\2]", ""):match("%z(%Z*)")
  if a then
    return "s/" .. a .. "//"
  end
end

local function split(str, delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(str, delimiter, from, true)
  while delim_from do
    if delim_from ~= 1 then
      table.insert(result, string.sub(str, from, delim_from - 1))
    end
    from = delim_to + 1
    delim_from, delim_to = string.find(str, delimiter, from, true)
  end
  if from <= #str then
    table.insert(result, string.sub(str, from))
  end
  return result
end
local function perform_sub(string, sub_exp)
  print("Perform sub")
  print(vim.inspect(sub_exp))
  local args = { "nvim_pcre", vim.fn.shellescape(table.concat(string, "\n")), sub_exp }
  local handle = io.popen(table.concat(args, " "))
  local new_lines = handle:read("*a")
  handle:close()
  return split(new_lines, "\n")
end
local function perl_sub(opts)
  print("persub")
  local line1 = opts.line1
  local line2 = opts.line2
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, 0)
  local sub_exp = parse_sub_exp(opts.args)
  local new_lines = perform_sub(lines, sub_exp)
  vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, 0, new_lines)

  -- local args = { table.concat(lines, "\n"), sub_exp }
  -- local curl = require("plenary.curl")
  -- local resp = curl.get("http://localhost:4812/check")

  -- local query = { text = table.concat(lines, "\n"), sub = sub_exp }
  -- local resp = curl.get("http://localhost:4812/", { query = query })
  -- local job = require("plenary.job")
  -- job
  --   :new({
  --     command = "nvim_pcre",
  --     args = args,
  --     on_exit = function(j, exit_code)
  --       if exit_code ~= 0 then
  --         print("error " .. exit_code .. " " .. vim.inspect(j))
  --       else
  --         vim.schedule(function()
  --           vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, 0, j:result())
  --         end)
  --       end
  --     end,
  --   })
  --   :start()
  -- vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, 0, new_lines)
end

local function perl_sub_preview(opts, preview_ns, preview_buf)
  local line1 = opts.line1
  local line2 = opts.line2
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, 0)
  local preview_buf_line = 0
  local lhs, rhs, flags = opts.args:match("^%/(.-)%/(.-)%/(.-)$")
  for i, line in ipairs(lines) do
    local getIndex
    if string.find(flags, "g") then
      getIndex = 'my @ret; while ("'
        .. line
        .. '" =~ /'
        .. lhs
        .. "/"
        .. flags
        .. ') { push @ret, \\$-[0] . "," . \\$+[0]; }; print join "|", @ret;'
    else
      getIndex = '"' .. vim.fn.escape(line, '"') .. '" =~ /' .. vim.fn.escape(lhs, '"') .. '/; print \\$-[0] . "," . \\$+[0];'
    end
    getIndex = vim.fn.shellescape(getIndex, 0)
    local indexString = vim.fn.system("perl -CSDA -e 'use utf8;' -e '#line 1 \"PerlSubstitute\"' -e " .. '"' .. getIndex .. '"')
    for x, y in string.gmatch(indexString, "(%d),(%d)(%|-)") do
      local startidx = tonumber(x)
      local endidx = tonumber(y)
      if startidx then
        vim.api.nvim_buf_add_highlight(buf, preview_ns, "Substitute", line1 + i - 2, startidx - 1, endidx)
        if preview_buf then
          local prefix = string.format("|%d| ", line1 + i - 1)
          vim.api.nvim_buf_set_lines(preview_buf, preview_buf_line, preview_buf_line, 0, { prefix .. line })
          vim.api.nvim_buf_add_highlight(preview_buf, preview_ns, "Substitute", preview_buf_line, #prefix + startidx - 1, #prefix + endidx)
        end
      end
      preview_buf_line = preview_buf_line + 1
    end
  end
  return 1
end
-- Create the user command
-- vim.api.nvim_create_user_command('PerlSub', perl_sub, { nargs = 1, range = 0, addr = 'lines' })
local M = {}

function M.setup()
  require("live-command").setup({
    defaults = {
      enable_highlighting = true,
      inline_highlighting = true,
    },
    commands = {
      PS = { cmd = "PS" },
    },
  })

  vim.api.nvim_create_user_command("PS", perl_sub, {
    nargs = 1,
    range = 0,
    -- addr = 'lines',
    preview = function(opts, preview_ns, preview_buf)
      print("PerlSub preview called")
      return require("live-command").command_preview(opts, preview_ns, preview_buf)
    end,
  })
end

return M
