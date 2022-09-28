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
