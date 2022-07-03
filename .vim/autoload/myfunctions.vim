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
