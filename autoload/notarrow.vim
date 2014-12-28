let s:buffer_name = '{notarrow}'
let s:buffer_nr = bufexists(s:buffer_name) ? bufnr(s:buffer_name) : -1

function! s:all() abort
  return filter(range(1, bufnr('$')), 'bufexists(v:val)')
endfunction

function! s:unlisted() abort
  return filter(s:all(), '!buflisted(v:val)')
endfunction

function! s:listed() abort
  return filter(s:all(), 'buflisted(v:val)')
endfunction

function! s:loaded() abort
  return filter(s:all(), 'bufloaded(v:val)')
endfunction

function! s:hidden() abort
  return filter(s:all(), '!bufloaded(v:val)')
endfunction 

function! s:modified() abort
  return filter(s:listed(), 'getbufvar(v:val, "&mod")')
endfunction

function! s:relevant() abort
  return filter(s:listed(), '!getbufvar(v:val, "notarrow_relevant", 0)')
endfunction

function! s:relevant() abort
  return filter(s:listed(), 'getbufvar(v:val, "notarrow_relevant", 0)')
endfunction

function! s:buffer_names(buffers) abort
  return map(a:buffers, 'bufname(v:val) != "" ? bufname(v:val) : "[No Name]"')
endfunction

function! s:mark_relevant(buffer) abort
  call setbufvar(a:buffer, 'b:notarrow_relevant', 1) 
endfunction

function! s:clear_relevant() abort
  for l:buffer in s:all()
    try
      call setbufvar(l:buffer, 'b:notarrow_relevant', 0) 
    catch
      continue
    endtry
  endfor
endfunction

function! notarrow#exists() abort
  return bufnr(s:buffer_name) > -1
endfunction

function! notarrow#is_open() abort
  return bufwinnr(s:buffer_nr) > -1
endfunction

function! notarrow#debug() abort
  echom string(s:all())
  echom string(s:listed())
  echom string(s:relevant())
  echom s:buffer_nr
  echom notarrow#exists()
  echom notarrow#is_open()
endfunction

function! notarrow#open_buffer_window() abort
  if !notarrow#exists()
    exe 'keepa bel 10new ' . s:buffer_name 
    let s:buffer_nr = bufnr('%')
    let b:mode = 's'
  elseif !notarrow#is_open()
    exe 'keepa bel 10sb ' . s:buffer_nr
  elseif notarrow#is_open()
    exe 'keepa ' . bufwinnr(s:buffer_nr) . 'winc w'
  endif
endfunction

function! notarrow#buffer_settings() abort
  if bufnr('%') != s:buffer_nr
    throw 'trying to setup wrong buffer!'
  endif
  set ft=notarrow
  setl noswf nonu nobl nospell nocuc wfh
  setl fdc=0 fdl=99 tw=0 bt=nofile bh=hide
  if v:version > 702
    setl nornu noudf cc=0
  end
  syn sync fromstart
  set foldmethod=syntax
endfunction

function! notarrow#autocmds() abort
  exe 'au! * <buffer=' . s:buffer_nr .'>'
  exe 'autocmd Bufleave <buffer=' . s:buffer_nr . '> :' . s:buffer_nr . 'winc q'
endfunction

function! notarrow#keybinds(c) abort
  "where a:c is the buffer where the plugin was invoked from
  exe 'nnoremap <silent> <buffer> <c-h> :call notarrow#toggle_mode(' . a:c . ')<CR>'
  exe 'nnoremap <silent> <buffer> <CR> :call notarrow#open_buffer(' . a:c . ')<CR>'
endfunction

function! notarrow#toggle_mode(c) abort
  let b:mode = b:mode == '*' ? '' : '*' 
  call notarrow#populate(a:c)
endfunction

function! notarrow#open_buffer(c) abort
  "where a:c is the buffer where the plugin was invoked from
  if len(b:buffers) < 1
    return
  endif
  let l:target_buffer = b:buffers[line('.')-1]
  exe bufwinnr(a:c) . 'winc w'
  exe 'buf' l:target_buffer
endfunction

function! notarrow#setup() abort
  let l:current = bufnr('%')
  call notarrow#open_buffer_window()
  call notarrow#buffer_settings() 
  call notarrow#populate(l:current)
  call notarrow#autocmds()
  call notarrow#keybinds(l:current)
endfunction

function! notarrow#new_buffer() abort
  let l:buffer = s:all()[-1] 
  if buflisted(l:buffer)
    call setbufvar(l:buffer, 'notarrow_relevant', 1)
  endif
endfunction


function! notarrow#format_buffer_path(b, c) abort
  "where a:b is the buffer number and a:c is the buffer that the plugin was
  "invoked from
  let l:formatted_path = '  ' . a:b
  let l:buffer_path = bufname(a:b)
  let l:current = a:b == a:c
  let l:alternate = bufexists('#') && bufnr('#') == a:b
  let l:relevant = getbufvar(a:b, 'notarrow_relevant', 0)
  let l:modified = getbufvar(a:b, '&modified', 0)
  if l:current
    let l:formatted_path .= '  %'
  elseif l:alternate
    let l:formatted_path .= '  #'
  elseif l:relevant
    let l:formatted_path .= '  *'
  else
    let l:formatted_path .= '   '
  endif
  if l:modified
    let l:formatted_path .= '+ '
  else
    let l:formatted_path .= '  '
  endif   
  let l:formatted_path .= expand(bufname(a:b))
  return l:formatted_path
endfunction

function! notarrow#populate(c) abort
  "where a:c is the buffer where the plugin was invoked from
  if bufnr('%') != s:buffer_nr
    throw 'trying to populate wrong buffer!'
  endif
  set ma
  norm! gg"_dG
  if b:mode == '*'
    let b:buffers = s:relevant()
  else
    let b:buffers = s:listed()
  endif
  if len(b:buffers) < 10
    exe 'res' max([1, len(b:buffers)])
  endif
  let l:buffer_paths = map(copy(b:buffers), 'notarrow#format_buffer_path(v:val, a:c)')
  call append(0, l:buffer_paths)
  norm! G"_dd
  exe 'norm! G' . (index(b:buffers, a:c) - 1)
  set noma
endfunction
