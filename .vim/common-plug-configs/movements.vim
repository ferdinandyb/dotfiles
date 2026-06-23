" if has('nvim')
"     Plug 'ggandor/lightspeed.nvim'
"     map í <Plug>Lightspeed_s
"     map Í <Plug>Lightspeed_S
" else
"     Plug 'justinmk/vim-sneak'
"     map í <Plug>Sneak_s
"     map Í <Plug>Sneak_S
"     let g:sneak#label = 1
"     Plug 'unblevable/quick-scope'
"     let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
"     let g:qs_max_chars=150
" endif
Plug 'justinmk/vim-sneak'
Plug 'unblevable/quick-scope'

let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
let g:qs_max_chars=150
map í <Plug>Sneak_s
map Í <Plug>Sneak_S
map , <Plug>Sneak_;
map ; <Plug>Sneak_,
let g:sneak#label = 1


autocmd User SneakLeave highlight clear Sneak
autocmd User PlugLoaded ++nested highlight Sneak ctermfg=84 guifg=#50FA7B ctermbg=237 guibg=#343746
autocmd User PlugLoaded ++nested highlight link SneakScope DraculaBgLight
