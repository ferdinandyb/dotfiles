nnoremap <buffer> dq :.,$global/^>\($\<bar>\s\)/delete<CR>:noh<cr>
setlocal spell! spelllang=en_gb,hu
set formatoptions-=r
set ff=unix
set columns=90
set textwidth=0
set wrap
augroup loading goyo " {
    autocmd!
    autocmd BufReadPost call goyo#execute(0,[])
    autocmd BufReadPost echo "hello"
augroup END " }
" let b:auto_save = 1
" let b:auto_save_events = ["InsertLeave", "TextChanged"]

nmap <leader>i 3]<space>jji
nmap <leader>s }o




nnoremap <leader>a :call contactfunction#insertAddressAerc()<CR>
nnoremap <leader>A :call contactfunction#insertAddress()<CR>


nnoremap <buffer> <leader>t :call insertlinesfzf#insertlines('~/.config/emailconfiguration/trailers')<CR>



let b:coc_enabled = 0
let b:ale_enabled = 0
let b:ale_fix_on_save = 0
