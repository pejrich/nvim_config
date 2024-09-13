" Title: lopsided.nvim
" Description: make lopsided text objects

if exists("g:loaded_lopsided_nvim")
  finish
endif
let g:loaded_lopsided_nvim = 1

let s:lua_rocks_deps_loc = expand("<sfile>:h:r") . "/../lua/lopsided.nvim/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" command! -nargs=0 NvimPortalList lua require("lopsided.nvim").list()
" command! -nargs=0 NvimPortalOut lua require("lopsided.nvim").out()
" command! -nargs=0 NvimPortalIn lua require("lopsided.nvim").in()
