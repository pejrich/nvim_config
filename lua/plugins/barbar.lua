local M = {}

function M.setup()
  local barbar = require("barbar")
  local state = require("barbar.state")
  local render = require("barbar.ui.render")
  local harpoon = require("harpoon")
  barbar.setup({
    icons = {
      buffer_index = true,
      alternate = { filetype = { enabled = false } },
      buffer_number = false,
      button = "",
      filetype = { custom_colors = true, enabled = true },
      pinned = { button = "", filename = true, buffer_index = false },
      diagnostics = { { enabled = false } },
    },
  })
  local function unpin_all()
    for _, buf in ipairs(state.buffers) do
      local data = state.get_buffer_data(buf)
      data.pinned = false
    end
  end

  local function get_buffer_by_mark(mark)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local buffer_path = vim.api.nvim_buf_get_name(buf)

      if buffer_path == "" or mark.value == "" then
        goto continue
      end

      local mark_pattern = mark.value:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
      if string.match(buffer_path, mark_pattern) then
        return buf
      end

      local buffer_path_pattern = buffer_path:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
      if string.match(mark.value, buffer_path_pattern) then
        return buf
      end

      ::continue::
    end
  end

  local function refresh_all_harpoon_tabs()
    local list = harpoon:list()
    unpin_all()
    for _, mark in ipairs(list.items) do
      local buf = get_buffer_by_mark(mark)
      if buf == nil then
        vim.cmd("badd " .. mark.value)
        buf = get_buffer_by_mark(mark)
      end
      if buf ~= nil then
        state.toggle_pin(buf)
      end
    end
    render.update()
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufLeave", "User" }, {
    callback = refresh_all_harpoon_tabs,
  })
end

function M.keymaps()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }

  local wk = require("which-key")
  local l = function(key)
    return "<leader>" .. key
  end

  wk.add({
    { l("q"), "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>", desc = "[Q]uit buffer" },
    { l("1"), "<cmd>BufferLineGoToBuffer 1<cr>", desc = "[B]uffer [1]" },
    { l("2"), "<cmd>BufferLineGoToBuffer 2<cr>", desc = "[B]uffer [2]" },
    { l("3"), "<cmd>BufferLineGoToBuffer 3<cr>", desc = "[B]uffer [3]" },
    { l("4"), "<cmd>BufferLineGoToBuffer 4<cr>", desc = "[B]uffer [4]" },
    { l("5"), "<cmd>BufferLineGoToBuffer 5<cr>", desc = "[B]uffer [5]" },
    { l("6"), "<cmd>BufferLineGoToBuffer 6<cr>", desc = "[B]uffer [6]" },
    { l("7"), "<cmd>BufferLineGoToBuffer 7<cr>", desc = "[B]uffer [7]" },
    { l("8"), "<cmd>BufferLineGoToBuffer 8<cr>", desc = "[B]uffer [8]" },
    { l("9"), "<cmd>BufferLineGoToBuffer 9<cr>", desc = "[B]uffer [9]" },
    { l("["), "<cmd>BufferLineCyclePrev<cr>", desc = "[B]uffer [P]rev" },
    { l("]"), "<cmd>BufferLineCycleNext<cr>", desc = "[B]uffer [N]ext" },
  })
  -- wk.add({
  --   { l("q"), "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>", desc = "[Q]uit buffer" },
  --   -- { l("q"), "<cmd>BufferClose<CR>", desc = "[Q]uit buffer" },
  --   { l("1"), "<cmd>BufferGoto 1<cr>", desc = "[B]uffer [1]" },
  --   { l("2"), "<cmd>BufferGoto 2<cr>", desc = "[B]uffer [2]" },
  --   { l("3"), "<cmd>BufferGoto 3<cr>", desc = "[B]uffer [3]" },
  --   { l("4"), "<cmd>BufferGoto 4<cr>", desc = "[B]uffer [4]" },
  --   { l("5"), "<cmd>BufferGoto 5<cr>", desc = "[B]uffer [5]" },
  --   { l("6"), "<cmd>BufferGoto 6<cr>", desc = "[B]uffer [6]" },
  --   { l("7"), "<cmd>BufferGoto 7<cr>", desc = "[B]uffer [7]" },
  --   { l("8"), "<cmd>BufferGoto 8<cr>", desc = "[B]uffer [8]" },
  --   { l("9"), "<cmd>BufferGoto 9<cr>", desc = "[B]uffer [9]" },
  --   { l("["), "<cmd>BufferPrevious<cr>", desc = "[B]uffer [P]rev" },
  --   { l("]"), "<cmd>BufferNext<cr>", desc = "[B]uffer [N]ext" },
  -- })
end

return M
