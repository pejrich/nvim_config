" Title: chuck_and_grab.nvim
" Description: chuck and grab lines from around the buffer

if exists("g:loaded_chuck_and_grab_nvim")
  finish
endif
let g:loaded_chuck_and_grab_nvim = 1

let s:lua_rocks_deps_loc = expand("<sfile>:h:r") . "/../lua/chuck_and_grab.nvim/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" command! -nargs=0 NvimPortalList lua require("chuck_and_grab.nvim").list()
" command! -nargs=0 NvimPortalOut lua require("chuck_and_grab.nvim").out()
" command! -nargs=0 NvimPortalIn lua require("chuck_and_grab.nvim").in()
