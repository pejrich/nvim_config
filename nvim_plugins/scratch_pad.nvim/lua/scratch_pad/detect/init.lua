local M = {}
local api = vim.api
local fn = vim.fn
local ts_provider = require("scratch_pad.detect.treesitter")()
local a = require("scratch_pad.detect.async")

-- local analyse_language = function(context)
--   local provider = ts_provider()
--   local code = context.code
--   return function(language)
--     -- return function()
--     --   return a.promise(function(resolve)
--     return
--     -- if score == nil then
--     --   return resolve()
--     -- end
--
--     -- return resolve({ language = language, score = score })
--     --   end)
--     -- end
--   end
-- end

-- local langs = nil
-- local skip = {
--   csv = true,
--   psv = true,
--   tsv = true,
--   org = true,
--   scheme = true,
--   racket = true,
--   markdown = true,
--   pem = true,
--   markdown_inline = true,
--   pod = true,
--   surface = true,
--   svelte = true,
--   rnoweb = true,
--   twig = true,
-- }
local langs = {
  elixir = 1,
  javascript = 1,
  python = 1,
  html = 1,
  css = 1,
  json = 1,
  lua = 1,
  rust = 1,
  typescript = 1,
  c = 1,
  sql = 1,
  ruby = 1,
  swift = 1,
}
function M.get_languages()
  return langs
  -- if langs then
  --   return langs
  -- end
  -- langs = {}
  -- for k, v in pairs(require("nvim-treesitter.parsers").get_parser_configs()) do
  --   if not skip[k] then
  --     langs[k] = 1
  --   end
  -- end
  -- for _, val in pairs(skip) do
  --   table[val] = nil
  -- end
  -- return langs
end
M.detect = function(bufnr)
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local code = table.concat(lines, "\n")
  local context = {
    code = code,
  }

  local f = function(language)
    return ts_provider.analyse(code, language)
  end
  local ret = {}
  for val, _ in pairs(M.get_languages()) do
    local status, resp = pcall(f, val)
    if not status then
      print("ERROR: " .. resp)
    else
      table.insert(ret, { val, resp })
    end
  end
  table.sort(ret, function(val1, val2)
    if val1[2] == val2[2] then
      return false
    end
    return val1[2] > val2[2]
  end)

  return ret
end
return M
