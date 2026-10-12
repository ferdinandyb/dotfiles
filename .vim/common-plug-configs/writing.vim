" need to have npm and yarn for markdown preview
Plug 'lervag/vimtex'
" alignment plugin
Plug 'godlygeek/tabular'
" Plug 'alok/notational-fzf-vim'
" Plug 'vim-pandoc/vim-pandoc'
" Plug 'vim-pandoc/vim-pandoc-syntax'

" These are overkill but good for inspiration

" vimtex setup
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_fold_enabled = 1
" let g:vimtex_quickfix_mode=0
" set conceallevel=1
" let g:tex_conceal='abdmg'

" usage of vimtex
" - need to start vim with `vim --servername vim`: should add alias
" - run :VimtexCompile to start compilation

let g:markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'python', 'lua', 'json']
