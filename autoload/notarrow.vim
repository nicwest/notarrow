let s:buffer_name = '{notarrow}'
let s:buffer_nr = bufexists(s:buffer_name) ? bufnr(s:buffer_name) : -1


function! notarrow#exists() abort
  return bufnr(s:buffer_name) > -1
endfunction

function! notarrow#is_open() abort
  return bufwinnr(s:buffer_nr) > -1
endfunction

function! notarrow#debug() abort
  echom string(notarrow#buffers#all())
  echom string(notarrow#buffers#listed())
  echom string(notarrow#buffers#relevant())
  echom s:buffer_nr
  echom notarrow#exists()
  echom notarrow#is_open()
endfunction


function! notarrow#open_buffer_window() abort
  " Function: creates, opens or focuses buffer with s:buffer_name
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

function! notarrow#setup() abort
  " Function: sets up the buffer the way we like it
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
  " Function: sets up autocmds
  exe 'autocmd! * <buffer=' . s:buffer_nr .'>'
  exe 'autocmd Bufleave <buffer=' . s:buffer_nr . '> :' . s:buffer_nr . 'winc q'
endfunction

function! notarrow#keybinds(b) abort
  " Where: a:b is the buffer where the plugin was invoked from
  exe 'nnoremap <silent> <buffer> <c-h> :call notarrow#toggle_mode(' . a:b . ')<CR>'
  exe 'nnoremap <silent> <buffer> <CR> :call notarrow#open_buffer(' . a:b . ')<CR>'
endfunction

function! notarrow#toggle_mode(b) abort
  " Where: a:b is the buffer where the plugin was invoked from
  let b:mode = b:mode == '*' ? '' : '*' 
  call notarrow#populate(a:b)
endfunction

function! notarrow#open_buffer(b) abort
  " Where: a:b is the buffer where the plugin was invoked from
  if len(b:buffers) < 1
    return
  endif
  let l:target_buffer = b:buffers[line('.')-1]
  exe bufwinnr(a:b) . 'winc w'
  exe 'buf' l:target_buffer
endfunction

function! notarrow#main() abort
  " Function: main call
  let l:current_buffer = bufnr('%')
  let l:current_window = winnr('%')
  call notarrow#open_buffer_window()
  call notarrow#setup() 
  call notarrow#populate(l:current_buffer, l:current_window)
  call notarrow#autocmds()
  call notarrow#keybinds(l:current_buffer, l:current_window)
endfunction

function! notarrow#buffer_add() abort
  " Function: marks new buffer as relevant, and adds it to order
  let l:buffer = notarrow#buffers#all()[-1] 
  if buflisted(l:buffer)
    call setbufvar(l:buffer, 'notarrow_relevant', 1)
  endif
endfunction

function! notarrow#buffer_window_enter() abort
  echom winnr()
endfunction


function! notarrow#format_buffer_path(b, cb) abort
  " Where: a:b is the buffer number and a:cb is the buffer that the plugin was
  " invoked from
  let l:formatted_path = '  ' . a:b
  let l:buffer_path = bufname(a:b)
  let l:current = a:b == a:cb
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

function! notarrow#populate(b) abort
  " Where: a:b is the buffer where the plugin was invoked from
  if bufnr('%') != s:buffer_nr
    throw 'trying to populate wrong buffer!'
  endif
  set ma
  norm! gg"_dG
  if b:mode == '*'
    let b:buffers = notarrow#buffers#relevant()
  else
    let b:buffers = notarrow#buffers#listed()
  endif
  if len(b:buffers) < 10
    exe 'res' max([1, len(b:buffers)])
  endif
  let l:buffer_paths = map(copy(b:buffers), 'notarrow#format_buffer_path(v:val, a:b)')
  call append(0, l:buffer_paths)
  norm! G"_dd
  exe 'norm! G' . (index(b:buffers, a:c) - 1)
  set noma
endfunction
