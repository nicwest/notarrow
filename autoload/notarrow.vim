let s:buffer_name = '{notarrow}'
let s:buffer_nr = bufexists(s:buffer_name) ? bufnr(s:buffer_name) : -1
let s:preview = 0
let s:mode = '*'


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
  echom s:mode
  echom s:preview
  echom notarrow#exists()
  echom notarrow#is_open()
endfunction


function! notarrow#open_buffer_window() abort
  " Function: creates, opens or focuses buffer with s:buffer_name
  if !notarrow#exists()
    exe 'keepa bel 10new ' . s:buffer_name 
    let s:buffer_nr = bufnr('%')
    let s:mode = 's'
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
  " Where: a:b is the current buffer
  " Function: sets up autocmds
  if bufnr('%') != s:buffer_nr
    throw 'trying to populate wrong buffer!'
  endif
  augroup notarrow_window
    autocmd!
    exe 'autocmd! <buffer=' . s:buffer_nr .'>'
    exe 'autocmd Bufleave <buffer=' . s:buffer_nr . '> call notarrow#close()'
  augroup END
endfunction

function! notarrow#close()
  if !s:preview
    exe s:buffer_nr . 'winc q'
  "else
    "let s:preview = 0
  endif
endfunction

function! notarrow#keybinds(b, w) abort
  " Where: a:b is the buffer where the plugin was invoked from, and a:w 
  " is the window where the plugin was invoked from
  if bufnr('%') != s:buffer_nr
    throw 'trying to populate wrong buffer!'
  endif
  exe 'nnoremap <silent> <buffer> <nowait> <c-h> :call notarrow#toggle_mode(' . a:b . ', ' . a:w . ')<CR>'
  exe 'nnoremap <silent> <buffer> <nowait> <space> :call notarrow#toggle_relevant(' . a:b . ', ' . a:w .')<CR>'
  exe 'nnoremap <silent> <buffer> <nowait> <CR> :call notarrow#open_buffer(' . a:b . ')<CR>'
  exe 'nnoremap <silent> <buffer> <nowait> q :norm! ZQ<CR>'
endfunction

function! notarrow#toggle_mode(b, w) abort
  " Where: a:b is the buffer where the plugin was invoked from
  let s:mode = s:mode == '*' ? '' : '*' 
  echo 'notarrow mode: ' . s:mode
  call notarrow#populate(a:b, a:w)
endfunction

function! notarrow#toggle_relevant(b, w) abort
  " Where: a:b is the buffer where the plugin was invoked from
  let l:relevant = getbufvar(a:b, 'notarrow_relevant', 0) ? 0 : 1
  call setbufvar(a:b, 'notarrow_relevant', l:relevant)
  call notarrow#populate(a:b, a:w)
endfunction

function! notarrow#open_buffer(b) abort
  " Where: a:b is the buffer where the plugin was invoked from
  if len(b:buffers) < 1
    return
  endif
  let l:target_buffer = b:buffers[line('.')-1]
  sil exe bufwinnr(a:b) . 'winc w'
  sil exe 'buf' l:target_buffer
endfunction

function! notarrow#main() abort
  " Function: main call
  let l:current_buffer = bufnr('%')
  let l:current_window = winnr()
  call notarrow#open_buffer_window()
  call notarrow#setup() 
  call notarrow#populate(l:current_buffer, l:current_window)
  call notarrow#autocmds()
  call notarrow#keybinds(l:current_buffer, l:current_window)
endfunction

function! notarrow#next() abort
  " Function: main call
  let l:current_buffer = bufnr('%')
  let l:current_window = winnr()
  if l:current_buffer == s:buffer_nr 
    return
  endif
  let s:preview = 1
  if s:mode == '*'
    let l:order = notarrow#order#relevant(l:current_buffer, l:current_window)
  else
    let l:order = notarrow#order#listed(l:current_buffer, l:current_window)
  endif
  echom string(l:order)
  if len(l:order) > 1
    let l:buffer = l:order[1]
    call notarrow#open_buffer_window()
    call notarrow#setup() 
    call notarrow#populate(l:buffer, l:current_window)
    call notarrow#autocmds()
    augroup notarrow_buffer
      exe 'autocmd CursorMoved,InsertEnter,TextChanged,CursorHold <buffer=' . l:buffer . '> call notarrow#close()'
    augroup END
    call notarrow#keybinds(l:buffer, l:current_window)
    sil exe l:current_window . 'winc w'
    sil exe 'buf' l:buffer
  endif
  let s:preview = 0
endfunction

function! notarrow#buffer_window_enter() abort
  let l:window = winnr()
  let l:buffer = winbufnr(l:window)
  if buflisted(l:buffer)
    call setbufvar(l:buffer, 'notarrow_relevant', 1)
    if !s:preview
      call notarrow#order#add(l:buffer, l:window)
    else
      call notarrow#order#rotate(l:buffer, l:window)
    endif
  endif
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

function! notarrow#populate(b, w) abort
  " Where: a:b is the buffer where the plugin was invoked from, and a:w 
  " is the window where the plugin was invoked from
  if bufnr('%') != s:buffer_nr
    throw 'trying to populate wrong buffer!'
  endif
  set ma
  norm! gg"_dG
  if s:mode == '*'
    let b:buffers = notarrow#order#relevant(a:b, a:w)
  else
    let b:buffers = notarrow#order#listed(a:b, a:w)
  endif
  if len(b:buffers) < 10
    exe 'res' max([1, len(b:buffers)])
  endif
  let l:buffer_paths = map(copy(b:buffers), 'notarrow#format_buffer_path(v:val, a:b)')
  call append(0, l:buffer_paths)
  norm! G"_dd
  exe 'norm! G' . (index(b:buffers, a:b) - 1)
  set noma
endfunction
