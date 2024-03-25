local function diff_strings(str1, str2)
  local diff = vim.diff(table.concat(str1), str2, { result_type = 'indices' })
  return diff
end

local function newlinesplit(str)
  local result = {}
  for line in string.gmatch(str .. '\n', '(.-)\n') do
    table.insert(result, line)
  end
  return result
end

local function parse_sub_exp(str)
  local pat, rep, mod = str:match '^%/([^/]+)%/*([^/]*)%/*(.-)$'
  local sub = 's/' .. (pat or '') .. '/' .. (rep or '') .. '/' .. (mod or '')
  return sub
end

local function perform_sub(string, sub_exp)
  local new_lines =
    vim.fn.system("perl -CSDA -e 'use utf8;' -e '#line 1 \"PerlSubstitute\"' -pe " .. vim.fn.shellescape(vim.fn.escape(sub_exp, '%!') .. ';'), string)
  return new_lines
end
local function perl_sub(opts)
  local line1 = opts.line1
  local line2 = opts.line2
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, 0)
  local sub_exp = parse_sub_exp(opts.args)
  local new_lines = perform_sub(lines, sub_exp)
  vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, 0, newlinesplit(new_lines))
end

local function perl_sub_preview(opts, preview_ns, preview_buf)
  local line1 = opts.line1
  local line2 = opts.line2
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, 0)
  local preview_buf_line = 0
  local lhs, rhs, flags = opts.args:match '^%/(.-)%/(.-)%/(.-)$'
  for i, line in ipairs(lines) do
    local getIndex
    if string.find(flags, 'g') then
      getIndex = 'my @ret; while ("' .. line .. '" =~ /' .. lhs .. '/' .. flags .. ') { push @ret, \\$-[0] . "," . \\$+[0]; }; print join "|", @ret;'
    else
      getIndex = '"' .. vim.fn.escape(line, '"') .. '" =~ /' .. vim.fn.escape(lhs, '"') .. '/; print \\$-[0] . "," . \\$+[0];'
      -- getIndex = "'" .. vim.fn.escape(line, '%!') .. "' =~ /" .. vim.fn.escape(lhs, '%!') .. "/; print \\$-[0] . ',' . \\$+[0];"
    end
    getIndex = vim.fn.shellescape(getIndex, 0)
    local indexString = vim.fn.system("perl -CSDA -e 'use utf8;' -e '#line 1 \"PerlSubstitute\"' -e " .. '"' .. getIndex .. '"')
    for x, y in string.gmatch(indexString, '(%d),(%d)(%|-)') do
      local startidx = tonumber(x)
      local endidx = tonumber(y)
      if startidx then
        vim.api.nvim_buf_add_highlight(buf, preview_ns, 'Substitute', line1 + i - 2, startidx - 1, endidx)
        if preview_buf then
          local prefix = string.format('|%d| ', line1 + i - 1)
          vim.api.nvim_buf_set_lines(preview_buf, preview_buf_line, preview_buf_line, 0, { prefix .. line })
          vim.api.nvim_buf_add_highlight(preview_buf, preview_ns, 'Substitute', preview_buf_line, #prefix + startidx - 1, #prefix + endidx)
        end
      end
      preview_buf_line = preview_buf_line + 1
    end
  end
  return 1
end
-- Create the user command
-- vim.api.nvim_create_user_command('PerlSub', perl_sub, { nargs = 1, range = 0, addr = 'lines' })
return {
  {
    'smjonas/live-command.nvim',
    -- live-command supports semantic versioning via tags
    -- tag = "1.*",
    config = function()
      require('live-command').setup {
        defaults = {
          enable_highlighting = true,
          inline_highlighting = true,
        },
        commands = {
          S = { cmd = 'PerlSub' },
        },
      }

      vim.api.nvim_create_user_command('PerlSub', perl_sub, {
        nargs = 1,
        range = 0,
        -- addr = 'lines',
        preview = function(opts, preview_ns, preview_buf)
          -- perl_sub_preview(opts, preview_ns, preview_buf)
          return require('live-command').command_preview(opts, preview_ns, preview_buf)
        end,
      })
    end,
  },
}
