" Used for local development, with vim-scriptease
let s:path = expand('<sfile>:p:h')
exe 'Runtime'  s:path . '/plugin/notarrow.vim' 
exe 'Runtime'  s:path . '/autoload/notarrow.vim'
exe 'Runtime'  s:path . '/autoload/notarrow/buffers.vim'
exe 'Runtime'  s:path . '/autoload/notarrow/order.vim'
