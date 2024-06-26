local M = {}

function M.commands()
  local c = {
    command = {
      ["<C-f>"] = "Open commands in window",
      ["<C-b>"] = "Go to beginning",
      ["<C-e>"] = "Go to end",
    },
    normal = {
      ["<C-^>"] = "Alt file",
      ["*/#"] = "Search under cursor fwd/bwd",
      ["%"] = "Matching brace",
    },
  }

  local lines = {}
  for k, v in pairs(c) do
    table.insert(lines, ("            --- " .. k:upper() .. " ---"))
    for k2, v2 in pairs(v) do
      local len = k2:len()
      local flank = (10 - len) / 2
      local prefix = string.rep(" ", math.floor(flank)) .. k2 .. string.rep(" ", math.ceil(flank))
      table.insert(lines, (prefix .. "  |  " .. v2))
    end
    table.insert(lines, "")
  end
  return lines
end

return M
