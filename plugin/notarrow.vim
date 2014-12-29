command! NotArrow :call notarrow#setup() 
command! NotArrowDebug :call notarrow#debug()

nnoremap <silent> <c-b> :NotArrow<CR>

autocmd BufAdd * call notarrow#buffer_add()
autocmd BufWinenter * call notarrow#buffer_window_enter()
