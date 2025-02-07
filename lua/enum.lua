local M = {}

function M.slice(enum, opts)
  local start = opts.start or 1
  if start < 0 then
    start = #enum + start + 1
  end
  if (opts.stop or 0) < 0 then
    opts.stop = #enum + opts.stop + 1
  end
  local len = opts.len or opts.length or ((opts.stop or #enum) + 1 - start)
  local ret = {}
  for i = start, start + len - 1 do
    ret[#ret + 1] = enum[i]
  end
  return ret
end

return M
