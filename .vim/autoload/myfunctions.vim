function! myfunctions#show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (len(bibtexcite#getfilepath('pandoc')) > 1)
    call bibtexcite#openfile('pandoc')
  elseif (len(bibtexcite#getfilepath('latex')) > 1)
    call bibtexcite#openfile('latex')
  elseif (len(bibtexcite#getcitekey('pandoc')) > 1)
    call bibtexcite#showcite('pandoc')
  elseif (len(bibtexcite#getcitekey('latex')) > 1)
    call bibtexcite#showcite('latex')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction


function! myfunctions#coc_toggle()
    if exists('g:did_coc_loaded')
        if g:coc_enabled
            CocDisable
        else
            CocEnable
        endif
    endif
endfunction

function! myfunctions#ale_fix_toggle()
    if exists('b:ale_fix_on_save')
        if b:ale_fix_on_save
            let b:ale_fix_on_save = 0
        else
            let b:ale_fix_on_save = 1
        endif
    else
        if g:ale_fix_on_save
            let b:ale_fix_on_save = 0
        else
            let b:ale_fix_on_save = 1
        endif
    endif
endfunction

function! myfunctions#set_softwrap()
  set columns=90
  set textwidth=0
  set wrap
endfunction

function! myfunctions#set_hardwrap()
  " silent !tput cols
  set textwidth=80
  set nowrap
endfunction


function! myfunctions#make_thousand_separators_get_word(word)
    if a:word =~ '\<\d\.\d\+[eE]+\d\+\>'
        let l:parts = split(a:word,'\ce+')
        let l:parts2 = split(l:parts[0],'\.')
        let znum = str2nr(l:parts[1]) - len(l:parts2[1])
        let l:cword = join(l:parts2) . repeat(0,l:znum)
    else
        let l:cword = a:word
    endif
    let l:newword = substitute(l:cword, '\(\.\d\+\)\@<!\d\ze\(\d\{3}\)\+\d\@!', '& ', 'g')
    return l:newword
endfunction

function! myfunctions#make_thousand_separators_word()
    let l:cword = expand('<cWORD>')
    execute 'norm! ciW' . myfunctions#make_thousand_separators_get_word(l:cword)
endfunction

function! myfunctions#make_thousand_separators_line()
    " add spaces as thousands separator for the current word under the cursor
    " TODO: do it on ranges: https://stackoverflow.com/questions/10572996/passing-command-range-to-a-function
    " TODO: make it dot repeatable
    let l:newline = []
    for word in split(getline(line('.')))
        call add(l:newline, myfunctions#make_thousand_separators_get_word(word))
    endfor
    let l:newline = join(l:newline)
    execute 'norm! cc' . l:newline
endfunction
