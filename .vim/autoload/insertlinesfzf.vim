
function! insertlinesfzf#insertinput(input) abort
    exec 'normal! a'  . a:input
endfunction

function! insertlinesfzf#insertlines(path)
    call fzf#run(fzf#wrap('insertrailer', {
    \ 'source':'cat ' . a:path,
    \ 'sink': function('insertlinesfzf#insertinput')
    \}))
endfunction
