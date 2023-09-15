nmap <buffer> <h <Plug>VimwikiRemoveHeaderLevel
nmap <buffer> >h <Plug>VimwikiAddHeaderLevel
nunmap <buffer> -
nunmap <buffer> =
nmap <buffer> ]w <Plug>VimwikiFollowLink
nmap <buffer> [w <Plug>VimwikiGoBackLink
nmap <buffer> ]sw <Plug>VimwikiSplitLink
nmap <buffer> ]vw <Plug>VimwikiVSplitLink

set foldlevel=1


function! DiaryWeeklyTemplate()
    let l:weekstart = expand('%:t:r')
    let l:ws_unix = strptime('%Y-%m-%d', l:weekstart)
    let l:weekend = strftime('%Y-%m-%d', l:ws_unix + 7*24*60*60)
    let l:weeknumber = strftime("%W", l:ws_unix)
    call append(line('$') - 1 , "# Week " . l:weeknumber)
    call append(line('$') - 1 , "")
    call append(line('$') - 1 , "")
    call append(line('$') - 1 , "")
    call append(line('$') - 1, "# Task reports")
    call append(line('$') - 1, "## completed | end.after:" . l:weekstart . " and end.before:". l:weekend)
    call append(line('$') - 1, "## added | entry.after:" . l:weekstart . " and entry.before:". l:weekend)
endfunction
