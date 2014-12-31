command! NotArrow :call notarrow#main() 
command! NotArrowDebug :call notarrow#debug()
command! NotArrowNext :call notarrow#next()

nnoremap <silent> <c-b> :NotArrow<CR>
nnoremap <silent> <c-f> :NotArrowNext<CR>

autocmd BufWinenter * call notarrow#buffer_window_enter()
