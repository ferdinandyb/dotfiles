nnoremap dq :.,$global/^>\($\<bar>\s\)/delete<CR>:noh<cr>
setlocal spell! spelllang=en_gb,hu
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

nmap <C-o> 3]<space>jji



function! InsertAddressAerc()
    call fzf#run(fzf#wrap("insertaddress", {
    \ 'source':'cat ~/.cache/maildir-rank-addr/addressbook.tsv',
    \ 'sink*': function("InsertContacts"),
    \ 'options': '--no-sort -i --multi'
    \}))
endfunction

function! InsertContacts(names) abort
    for name in a:names
        call InsertContact(name)
    endfor
endfunction

function! InsertContact(name) abort
    let [address, name, uname] = split(a:name,"\t")
    call append(line('.'), '    ' . name . " <" . address . ">,")
endfunction

nnoremap <leader>a :call InsertAddressAerc()<CR>
