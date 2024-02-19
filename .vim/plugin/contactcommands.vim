function! InsertAddressAerc()
    call fzf#run(fzf#wrap("insertaddress", {
    \ 'source':'cat ~/.cache/maildir-rank-addr/addressbook.tsv',
    \ 'sink*': function("InsertContactsLine"),
    \ 'options': '--no-sort -i --multi --exact'
    \}))
endfunction

function! InsertAddress()
    call fzf#run(fzf#wrap("insertaddress", {
    \ 'source':'cat ~/.cache/maildir-rank-addr/addressbook.tsv',
    \ 'sink': function("InsertContact"),
    \ 'options': '--no-sort -i --exact'
    \}))
endfunction

function! InsertContactsLine(names) abort
    for name in a:names
        call InsertContactLine(name)
    endfor
endfunction

function! InsertContactLine(name) abort
    let [address, name; rest] = split(a:name,"\t")
    call append(line('.'), '    ' . name . " <" . address . ">,")
endfunction

function! InsertContact(name) abort
    let [address, name; rest] = split(a:name,"\t")
    exec 'normal! a'  . name . " <" . address . ">\<Esc>"
endfunction
