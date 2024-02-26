function! myfunctions#show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (len(bibtexcite#getfilepath("pandoc")) > 1)
    call bibtexcite#openfile("pandoc")
  elseif (len(bibtexcite#getfilepath("latex")) > 1)
    call bibtexcite#openfile("latex")
  elseif (len(bibtexcite#getcitekey("pandoc")) > 1)
    call bibtexcite#showcite("pandoc")
  elseif (len(bibtexcite#getcitekey("latex")) > 1)
    call bibtexcite#showcite("latex")
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


function! myfunctions#make_thousand_separators()
    " add spaces as thousands separator for the current word under the cursor
    " TODO: do it on ranges: https://stackoverflow.com/questions/10572996/passing-command-range-to-a-function
    " TODO: make it dot repeatable
    let l:cword = expand("<cword>")
    let l:newword = substitute(l:cword, '\(\d,\d*\)\@<!\d\ze\(\d\{3}\)\+\d\@!', '& ', 'g')
    exe "norm! ciw" . l:newword
endfunction
