function! notarrow#buffers#all() abort
  return filter(range(1, bufnr('$')), 'bufexists(v:val)')
endfunction

function! notarrow#buffers#unlisted() abort
  return filter(notarrow#buffers#all(), '!buflisted(v:val)')
endfunction

function! notarrow#buffers#listed() abort
  return filter(notarrow#buffers#all(), 'buflisted(v:val)')
endfunction

function! notarrow#buffers#loaded() abort
  return filter(notarrow#buffers#all(), 'bufloaded(v:val)')
endfunction

function! notarrow#buffers#hidden() abort
  return filter(notarrow#buffers#all(), '!bufloaded(v:val)')
endfunction 

function! notarrow#buffers#modified() abort
  return filter(notarrow#buffers#listed(), 'getbufvar(v:val, "&mod")')
endfunction

function! notarrow#buffers#relevant() abort
  return filter(notarrow#buffers#listed(), '!getbufvar(v:val, "notarrow_relevant", 0)')
endfunction

function! notarrow#buffers#relevant() abort
  return filter(notarrow#buffers#listed(), 'getbufvar(v:val, "notarrow_relevant", 0)')
endfunction

function! notarrow#buffers#buffer_names(buffers) abort
  return map(a:buffers, 'bufname(v:val) != "" ? bufname(v:val) : "[No Name]"')
endfunction

function! notarrow#buffers#mark_relevant(buffer) abort
  call setbufvar(a:buffer, 'b:notarrow_relevant', 1) 
endfunction

function! notarrow#buffers#clear_relevant() abort
  for l:buffer in notarrow#buffers#all()
    try
      call setbufvar(l:buffer, 'notarrow_relevant', 0) 
    catch
      continue
    endtry
  endfor
endfunction

function! notarrow#buffers#filter(b, f) abort
  " Where: a:b is a list of buffer numbers, and a:f is a list of buffer numbers
  " to filter by.
  " Returns: a list of buffer numbers containing only numbers
  " from a:b that are also in a:f 
  return filter(copy(a:b), 'index(a:f, v:val) > -1')
endfunction

function! notarrow#buffers#exclude(b, f) abort
  " Where: a:b is a list of buffer numbers, and a:f is a list of buffer numbers
  " to filter by.
  " Returns: a list of buffer numbers containing only numbers
  " from a:b that are not in a:f 
  return filter(copy(a:b), 'index(a:f, v:val) > -1')
endfunction
