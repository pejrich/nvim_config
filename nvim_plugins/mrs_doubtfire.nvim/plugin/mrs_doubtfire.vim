" Title: mrs_doubtfire.nvim
" Description: Mrs. Doubtfire . NVIM

if exists("g:loaded_mrs_doubtfire")
  finish
endif
let g:loaded_mrs_doubtfire = 1

let s:lua_rocks_deps_loc = expand("<sfile>:h:r") . "/../lua/mrs_doubtfire.nvim/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"
