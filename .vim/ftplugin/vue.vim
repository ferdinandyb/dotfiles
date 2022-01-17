au FileType vue silent! call s:set_vue_marks()
function! s:set_vue_marks()
    if search("data()","w")
        mark d
    endif
    if search("methods:","w")
        mark m
    endif
    if search("mounted()","w")
        mark l
    endif
endfunction

setlocal foldmethod=expr
