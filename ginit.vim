" Enable Mouse
set mouse=a

" Set Editor Font
    " Use GuiFont! to ignore font errors
    " if exists(':GuiFont')
    set guifont=FiraCode\ Nerd\ Font:h18
" endif

" Right Click Context Menu (Copy-Cut-Paste)
nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
xnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv
snoremap <silent><RightMouse> <C-G>:call GuiShowContextMenu()<CR>gv
