call plug#begin('~/.vim/plugged')
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'ferdinandyb/vim', { 'as': 'dracula' }
call plug#end()
colorscheme dracula
set laststatus=0

let g:firenvim_config = {
    \ 'localSettings': {
        \ '.*': {
            \ 'takeover': 'never',
        \ },
    \ }
\ }
