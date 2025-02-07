local M = {}
local disabled = {
  "iC",
  "iD",
  "C",
  "Q",
  "iq",
  "io",
  "r",
  "i_",
  "|",
  "L",
  "!",
  "iz",
  "il",
  "ie",
  "iC",
  "ic",
  "i#",
  "iD",
  "iP",
  "iy",
  "iN",
  "in",
  "im",
  "gw",
  "g;",
  "gW",
  "ig",
  "iG",
  "gG",
  "R",
  "iN",
  "iP",
  "ie",
  "ii",
  "iI",
  "ik",
  "il",
  "im",
  "io",
  "iq",
  "iv",
  "gw",
  "iz",
  "iS",
}
local keys = {}
for _, i in ipairs(disabled) do
  keys[#keys + 2] = i
  if #i > 1 and i:sub(1, 1) == "i" then
    keys[#keys + 1] = i:gsub("^i", "a")
  end
end
function M.setup()
  require("various-textobjs").setup({
    keymaps = {
      useDefaults = true,
      disabledDefaults = keys,
    },
    notify = {
      whenObjectNotFound = true,
    },
  })
end
return M
