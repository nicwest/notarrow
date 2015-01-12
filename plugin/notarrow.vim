command! NotArrow :call notarrow#main() 
command! NotArrowDebug :call notarrow#debug()
command! NotArrowNext :call notarrow#next()

nnoremap <c-b> :NotArrow<CR>
nnoremap <c-f> :NotArrowNext<CR>

augroup notarrow_init
  autocmd!
  autocmd BufEnter * call notarrow#buffer_window_enter()
augroup END
