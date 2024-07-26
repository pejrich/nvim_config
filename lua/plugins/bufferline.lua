local M = {}

function M.setup()
  vim.opt.termguicolors = true
  local colors = require("kanagawa.colors").setup()
  local theme_colors = colors.theme

  vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    callback = function()
      vim.api.nvim_set_hl(0, "MyHarpoonSelected", { fg = theme_colors.syn.preproc })
    end,
  })
  require("bufferline").setup({
    highlights = {
      fill = {
        bg = "#1F1F29",
      },
    },
    options = {
      numbers = function(opts)
        return string.format("%s", opts.raise(opts.ordinal))
      end,
      indicator = {
        style = "underline",
      },
      custom_areas = {
        left = function()
          local result = {}
          local items = require("harpoon"):list().items
          for i = 1, #items do
            local fn = items[i].value
            local fullpath = vim.fn.fnamemodify(fn, ":p")
            local name = " " .. i .. "> " .. vim.fn.fnamemodify(fn, ":t") .. " "
            local activename = " " .. i .. ">* " .. vim.fn.fnamemodify(fn, ":t") .. " "
            if fullpath == vim.fn.expand("%:p") then
              -- table.insert(result, { text = "│", link = "BufferLineIndicatorSelected" })
              -- table.insert(result, { text = name, link = "MyHarpoonSelected" })
              table.insert(result, { text = activename, link = "MyHarpoonSelected" })
              -- table.insert(result, { text = "│", link = "BufferLineIndicatorSelected" })
            else
              -- print('inactive: ' .. name)
              table.insert(result, { text = name, link = "BufferLineBufferVisible" })
            end
          end
          return result
        end,
      },
    },
  })
end

return M
