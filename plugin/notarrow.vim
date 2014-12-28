command! NotArrow :call notarrow#setup() 
command! NotArrowDebug :call notarrow#debug()

nnoremap <silent> <c-b> :NotArrow<CR>

autocmd BufAdd * call notarrow#new_buffer()
