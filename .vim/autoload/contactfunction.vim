function! contactfunction#insertAddressAerc()
    call fzf#run(fzf#wrap("insertaddress", {
    \ 'source':'addresslookup . 0',
    \ 'sink*': function("contactfunction#insertContactsLine"),
    \ 'options': '--no-sort -i --multi --exact'
    \}))
endfunction

function! contactfunction#insertAddress()
    call fzf#run(fzf#wrap("insertaddress", {
    \ 'source':'addresslookup . 0',
    \ 'sink': function("contactfunction#insertContact"),
    \ 'options': '--no-sort -i --exact'
    \}))
endfunction

function! contactfunction#insertContactsLine(names) abort
    for name in a:names
        call contactfunction#insertContactLine(name)
    endfor
endfunction

function! contactfunction#insertContactLine(name) abort
    let [address, name; rest] = split(a:name,"\t")
    call append(line('.'), '    ' . name . " <" . address . ">,")
endfunction

function! contactfunction#insertContact(name) abort
    let [address, name; rest] = split(a:name,"\t")
    exec 'normal! a'  . name . " <" . address . ">\<Esc>"
endfunction
