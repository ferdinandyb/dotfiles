nmap <buffer> <h <Plug>VimwikiRemoveHeaderLevel
nmap <buffer> >h <Plug>VimwikiAddHeaderLevel
nunmap <buffer> -
nunmap <buffer> =
nmap <buffer> ]w <Plug>VimwikiFollowLink
nmap <buffer> [w <Plug>VimwikiGoBackLink
nmap <buffer> ]sw <Plug>VimwikiSplitLink
nmap <buffer> ]vw <Plug>VimwikiVSplitLink




function! DiaryWeeklyTemplate()
    let l:weekstart = expand('%:r')
    let l:ws_unix = strptime('%Y-%m-%d', l:weekstart)
    let l:weekend = strftime('%Y-%m-%d', l:ws_unix + 7*24*60*60)
    let l:weeknumber = strftime("%W", l:ws_unix)
    call append(line('$') - 1 , "# Week " . l:weeknumber)
    call append(line('$') - 1 , "")
    call append(line('$') - 1 , "")
    call append(line('$') - 1 , "")
    call append(line('$') - 1, "# Task reports")
    call append(line('$') - 1, "## completed | end.after:2023-08-28 and end.before:2023-09-04")
    call append(line('$') - 1, "## added | entry.after:2023-08-28 and entry.before:2023-09-04")
endfunction
