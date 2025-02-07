local M = {}

local do_search = function(type, query, path)
  local rg_opts = type == "lit" and "-F" or ""
  vim.api.nvim_exec2([[Rg ]] .. rg_opts .. [[ "]] .. query:gsub('"', '\\"') .. [[" ]] .. path, { output = false })
end

M.history = {}
function M.search()
  local history_index = #M.history + 1
  local type = "lit"
  local ask_for_path = false
  local query = nil
  require("uiux").input({ prompt = "Query (" .. type .. "): " }, function(term)
    query = term
    if query == "" then
      M.search()
    else
      M.history[#M.history + 1] = query
      if ask_for_path then
        require("uiux").input({ prompt = "Path: ", default = "" }, function(input)
          do_search(type, query, input)
        end)
      else
        do_search(type, query, "")
      end
    end
  end, {
    {
      { "n", "i" },
      "<C-l>",
      function()
        type = type == "reg" and "lit" or "reg"
        return { prompt = "Query (" .. type .. "): " }
      end,
    },
    {
      { "n", "i" },
      "<up>",
      function()
        history_index = math.max(history_index - 1, 1)
        return { input = M.history[history_index] }
      end,
    },
    {
      { "n", "i" },
      "<down>",
      function()
        history_index = math.min(history_index + 1, #M.history + 1)
        return { input = M.history[history_index] or "" }
      end,
    },
    {
      { "n", "i" },
      "<S-CR>",
      function()
        ask_for_path = true
        local keys = vim.api.nvim_replace_termcodes("<Esc><CR>", true, true, true)
        vim.fn.feedkeys(keys)
      end,
    },
  })
end

function M.find_func_under_cursor()
  vim.api.nvim_feedkeys("yiw", "m", true)
  vim.defer_fn(function()
    local text = vim.fn.getreg("+")
    local start = vim.api.nvim_buf_get_mark(0, "<")
    local stop = vim.api.nvim_buf_get_mark(0, ">")
    do_search("lit", "def " .. text, "")
  end, 1)
end
return M
