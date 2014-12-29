let s:buffer_order = []

function! notarrow#order#window_init(b, w)
  " Where: a:b is a buffer number and a:w is a window number
  let l:window_order = getwinvar(a:w, 'notarrow_order', [])
  if len(l:window_order) < 1
    call setwinvar(a:w, 'notarrow_order', [a:b])
  endif
endfunction

function! notarrow#order#combined(w)
  " Where: a:w is a window number
  " Returns: a list containing the order of buffers from both window order and
  " buffer order with no repeats
  let l:window_order = getwinvar(a:w, 'notarrow_order', [])
  let l:buffer_order_excluded = notarrow#buffers#exclude(s:buffer_order, l:window_order)
  return l:window_order + l:buffer_order_excluded
endfunction

function! notarrow#order#remove(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  call filter(s:buffer_order, 'v:val != a:b')
endfunction

function! notarrow#order#add(b, ) abort
  " Where: a:b is a buffer number and a:w is a window number
  call notarrow#order#remove(a:b)
  call insert(s:buffer_order, a:b, 0)
endfunction

function! notarrow#order#all(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  return s:buffer_order
endfunction

function! notarrow#order#listed(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  return notarrow#buffers#filter(s:buffer_order, notarrow#buffers#listed())
endfunction

function! notarrow#order#loaded(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  return notarrow#buffers#filter(s:buffer_order, notarrow#buffers#loaded())
endfunction

function! notarrow#order#hidden(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  return notarrow#buffers#filter(s:buffer_order, notarrow#buffers#hidden())
endfunction

function! notarrow#order#hidden(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  return notarrow#buffers#filter(s:buffer_order, notarrow#buffers#hidden())
endfunction
