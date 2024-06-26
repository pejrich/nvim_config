-- Keymaps

_G.K = {}
-- Which key <leader> prefixed
_G.WK = {}
-- Which key non <leader> prefixed
_G.WKN = {}
_G.P = function(v)
  print(vim.inspect(v))
  return v
end
_G.F = {
  start_flame_profile = function()
    require("plenary.profile").start("profile.log", { flame = true })
  end,
  start_profile = function()
    require("plenary.profile").start("profile.log")
  end,
  stop_profile = function()
    require("plenary.profile").stop()
  end,
  delete_file_path = function()
    vim.cmd("!rm %:p")
  end,
  copy_file_path = function()
    vim.cmd("!echo -n %:p | pbcopy")
  end,
}

local default_keymap_options = { noremap = true, silent = true }

local function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

local function tableMerge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        tableMerge(t1[k] or {}, t2[k] or {})
      else
        if t1[k] then
          print("AAdding " .. tostring(k) .. " as " .. tostring(dump(v)) .. " was " .. tostring(dump(t1[k])))
        end
        t1[k] = v
      end
    else
      if t1[k] then
        print("Adding " .. tostring(k) .. " as " .. tostring(dump(v)) .. " was " .. tostring(dump(t1[k])))
      end
      t1[k] = v
    end
  end
  return t1
end

function K.merge_wk(table)
  tableMerge(WK, table)
end
function K.merge_wk_normal(table)
  tableMerge(WKN, table)
end

function K.map(mapping)
  -- NB!: it is important to remove items in reverse order to avoid shifting
  local cmd = table.remove(mapping, 3)
  local desc = table.remove(mapping, 2)
  local key = table.remove(mapping, 1)

  local mode = mapping["mode"]

  mapping["mode"] = nil
  mapping["desc"] = desc

  local options = vim.tbl_extend("force", default_keymap_options, mapping)

  vim.keymap.set(mode, key, cmd, options)
end

function K.mapseq(mapping)
  local wk = require("which-key")

  local keymap = {}

  -- NB!: it is important to remove items in reverse order to avoid shifting
  local cmd = table.remove(mapping, 3)
  local desc = table.remove(mapping, 2)
  local key = table.remove(mapping, 1)

  mapping[1] = cmd
  mapping[2] = desc

  keymap[key] = mapping

  wk.register(keymap, default_keymap_options)
end
