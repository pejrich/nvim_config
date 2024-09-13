local M = {}
local utils = require("utils")
local function update_from_resp(buf, resp)
  local curr_prompt = vim.fn.prompt_getprompt(buf)
  local pos = utils.cur_pos()
  local line = pos[1]
  local width = utils.line_width(line)
  local cursor_offset = width - pos[2]
  local text = vim.api.nvim_buf_get_text(buf, line - 1, #curr_prompt, line - 1, width, {})
  local new_prompt = resp.prompt or curr_prompt
  vim.fn.prompt_setprompt(buf, new_prompt)
  vim.defer_fn(function()
    line = utils.cur_pos()[1]
    width = utils.line_width(line)
    vim.api.nvim_buf_set_text(buf, line - 1, #new_prompt, line - 1, width, resp.input and { resp.input } or text)
    vim.api.nvim_win_set_cursor(0, { line, utils.line_width(line) - cursor_offset })
  end, 5)
end
local function wininput(opts, on_confirm, keymaps, win_opts)
  -- create a "prompt" buffer that will be deleted once focus is lost
  local buf = vim.api.nvim_create_buf(false, false)
  vim.bo[buf].buftype = "prompt"
  vim.bo[buf].bufhidden = "wipe"

  local prompt = opts.prompt or ""
  local default_text = opts.default or ""

  -- defer the on_confirm callback so that it is
  -- executed after the prompt window is closed
  local deferred_callback = function(input)
    vim.defer_fn(function()
      on_confirm(input)
    end, 10)
  end

  -- set prompt and callback (CR) for prompt buffer
  vim.fn.prompt_setprompt(buf, prompt)
  vim.fn.prompt_setcallback(buf, deferred_callback)

  -- set some keymaps: CR confirm and exit, ESC in normal mode to abort
  vim.keymap.set({ "i", "n" }, "<CR>", "<CR><Esc>:close!<CR>:stopinsert<CR>", {
    silent = true,
    buffer = buf,
  })
  vim.keymap.set("n", "<esc>", "<cmd>close!<CR>", {
    silent = true,
    buffer = buf,
  })

  if keymaps then
    for _, i in ipairs(keymaps) do
      local key_opts = i[4] or {}
      key_opts.buffer = buf
      local cb = function()
        local resp = i[3]()
        if resp then
          update_from_resp(buf, resp)
        end
      end
      vim.keymap.set(i[1], i[2], cb, key_opts)
    end
  end

  -- end, { expr = true, silent = true, buffer = buf })

  local default_win_opts = {
    relative = "editor",
    row = vim.o.lines / 2 - 1,
    col = vim.o.columns / 2 - 25,
    width = 50,
    height = 1,
    focusable = true,
    style = "minimal",
    border = "rounded",
  }

  win_opts = vim.tbl_deep_extend("force", default_win_opts, win_opts)

  -- adjust window width so that there is always space
  -- for prompt + default text plus a little bit
  win_opts.width = #default_text + #prompt + 5 < win_opts.width and win_opts.width or #default_text + #prompt + 5

  -- open the floating window pointing to our buffer and show the prompt
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_win_set_option(win, "winhighlight", "Search:None")

  vim.cmd("startinsert")

  -- set the default text (needs to be deferred after the prompt is drawn)
  vim.defer_fn(function()
    vim.api.nvim_buf_set_text(buf, 0, #prompt, 0, #prompt, { default_text })
    vim.cmd("startinsert!") -- bang: go to end of line
  end, 5)
end

function M.input(opts, on_confirm, keymaps)
  wininput(opts, on_confirm, keymaps, { border = "rounded", relative = "editor" })
end

return M
