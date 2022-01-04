call plug#begin('~/.vim/plugged')
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'ferdinandyb/vim', { 'as': 'dracula' }
Plug '907th/vim-auto-save'
call plug#end()

let g:auto_save_events = ["CursorHoldI","CursorHold"]
colorscheme dracula
set laststatus=0

let g:firenvim_config = {
    \ 'localSettings': {
        \ '.*': {
            \ 'takeover': 'never',
        \ },
    \ }
\ }
