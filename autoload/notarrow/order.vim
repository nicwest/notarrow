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
  "echom string(l:window_order)
  "echom string(l:buffer_order_excluded)
  return l:window_order + l:buffer_order_excluded
endfunction

function! notarrow#order#remove(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  call filter(s:buffer_order, 'v:val != a:b')
  let l:window_order = getwinvar(a:w, 'notarrow_order', [])
  call filter(l:window_order, 'v:val != a:b')
  call setwinvar(a:w, 'notarrow_order', l:window_order)
endfunction

function! notarrow#order#add(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  call notarrow#order#remove(a:b, a:w)
  call insert(s:buffer_order, a:b, 0)
  let l:window_order = getwinvar(a:w, 'notarrow_order', [])
  call insert(l:window_order, a:b, 0)
  call setwinvar(a:w, 'notarrow_order', l:window_order)
endfunction

function! notarrow#order#rotate(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  call notarrow#order#remove(a:b, a:w)
  call add(s:buffer_order, a:b)
endfunction

function! notarrow#order#all(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  " Returns: a combined list of both window and global buffer order,
  " a:b should always be at index 0
  return notarrow#order#combined(a:w)
endfunction

function! notarrow#order#listed(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  " Returns: a combinded list of both window and global buffer order, only
  " contains listed buffers, a:b should always be at index 0
  let l:combined = notarrow#order#combined(a:w)
  return notarrow#buffers#filter(l:combined, notarrow#buffers#listed())
endfunction

function! notarrow#order#loaded(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  " Returns: a combinded list of both window and global buffer order,
  " only contains loaded (buffers that are in window) buffers, a:b
  " should always be at index 0
  let l:combined = notarrow#order#combined(a:w)
  return notarrow#buffers#filter(l:combined, notarrow#buffers#loaded())
endfunction

function! notarrow#order#hidden(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  " Returns: a combinded list of both window and global buffer order,
  " only contains hidden (buffers that are not in window) buffers, a:b
  " should always be at index 0
  let l:combined = notarrow#order#combined(a:w)
  return notarrow#buffers#filter(l:combined, notarrow#buffers#hidden())
endfunction

function! notarrow#order#modified(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  " Returns: a combinded list of both window and global buffer order,
  " only contains modified buffers, a:b should always be at index 0
  let l:combined = notarrow#order#combined(a:w)
  return notarrow#buffers#filter(l:combined, notarrow#buffers#modified())
endfunction

function! notarrow#order#relevant(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  " Returns: a combinded list of both window and global buffer order,
  " only contains relevant buffers, a:b should always be at index 0
  let l:combined = notarrow#order#combined(a:w)
  return notarrow#buffers#filter(l:combined, notarrow#buffers#relevant())
endfunction

function! notarrow#order#notrelevant(b, w) abort
  " Where: a:b is a buffer number and a:w is a window number
  " Returns: a combinded list of both window and global buffer order,
  " only contains non-relevant buffers, a:b should always be at index 0
  let l:combined = notarrow#order#combined(a:w)
  return notarrow#buffers#filter(l:combined, notarrow#buffers#nonrelevant())
endfunction
