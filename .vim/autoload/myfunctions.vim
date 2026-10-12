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

function! myfunctions#quickfix_showfiles(range) abort
  let files = systemlist('git showfiles ' . shellescape(a:range) . ' --diff-filter=d | sort | uniq')
  call setqflist(map(files, '{"filename": v:val, "lnum": 1}'))
  copen
endfunction

function! myfunctions#prose_format_setup() abort
  setlocal textwidth=80
  " q  - let gq honour the list/blockquote leaders in 'comments'
  " n  - honour 'formatlistpat' so ordered lists hang correctly
  " -1 - '1' breaks before a one-letter word, turning a wrapped ' - ' into a bullet
  setlocal formatoptions+=qn formatoptions-=1
  let l:undo = 'setl tw< fo<'
  let b:undo_ftplugin = empty(get(b:, 'undo_ftplugin', '')) ? l:undo : b:undo_ftplugin . '|' . l:undo
endfunction

function! myfunctions#open_uri(uri) abort
  let l:cmd = (has('mac') || has('macunix')) ? 'open' : 'xdg-open'
  if !executable(l:cmd)
    echohl ErrorMsg | echomsg 'no URL opener: ' . l:cmd | echohl None
    return
  endif
  silent call system(l:cmd . ' ' . shellescape(a:uri))
  if v:shell_error
    echohl ErrorMsg | echomsg l:cmd . ' failed (' . v:shell_error . ')' | echohl None
  endif
endfunction

function! myfunctions#md_gf() abort
  let l:line = getline('.')
  let l:col = col('.')
  let l:start = 0
  let l:title_pat  = '\%(\s\+\%("[^"]*"\|''[^'']*''\|([^()]*)\)\)\?'
  let l:body_pat   = '\%(\\.\|<[^>]*>\|([^()]*)\|[^()[:space:]]\)\+'
  let l:target_pat = '\%(' . l:body_pat . l:title_pat . '\)'
  let l:pat = '\[[^\]]*\](' . l:target_pat . ')'
  while 1
    let l:full = matchstrpos(l:line, l:pat, l:start)
    if l:full[1] == -1 | break | endif
    let l:m_start = l:full[1] + 1
    let l:m_end = l:full[2]
    if l:col >= l:m_start && l:col <= l:m_end
      let l:seg = l:line[l:full[1] : l:full[2]-1]
      let l:target = matchstr(l:seg, '^\[[^\]]*\](\zs' . l:target_pat . '\ze)$')
      let l:target = trim(l:target)
      let l:target = substitute(l:target, '\s\+["''(].*$', '', '')
      let l:target = substitute(l:target, '^<\(.*\)>$', '\1', '')
      let l:target = substitute(l:target, '\\\([()]\)', '\1', 'g')
      if l:target =~? '^\a[a-z0-9+.-]*:'
        call myfunctions#open_uri(l:target)
        return
      elseif l:target =~# '^#'
        normal! m'
        let l:anchor = substitute(escape(l:target[1:], '\.*$^~[]'), '-', '[- ]', 'g')
        let l:heading_pat = '\c^#\+\s\+' . l:anchor
        let l:lnum = search(l:heading_pat, 'w')
        if l:lnum == 0
          echohl WarningMsg | echomsg 'Heading not found: ' . l:target | echohl None
        endif
        return
      else
        let l:path = substitute(l:target, '#.*$', '', '')
        if !empty(l:path)
          let l:resolved = (l:path =~# '^/' ? l:path : expand('%:p:h') . '/' . l:path)
          try
            execute 'edit ' . fnameescape(l:resolved)
          catch /^Vim\%((\a\+)\)\=:E/
            echohl ErrorMsg | echomsg v:exception | echohl None
          endtry
          return
        endif
      endif
    endif
    let l:start = l:full[2]
  endwhile

  let l:cfile = expand('<cfile>')
  if empty(l:cfile)
    echohl WarningMsg | echomsg 'No file name under cursor' | echohl None
    return
  endif

  try
    execute 'edit ' . fnameescape(l:cfile)
  catch /^Vim\%((\a\+)\)\=:E/
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfunction

function! myfunctions#md_fmt() abort
  if &filetype !=# 'markdown'
    echohl WarningMsg | echomsg 'MdFmt: not a markdown buffer' | echohl None
    return
  endif
  if !&modifiable || &readonly
    echohl WarningMsg | echomsg 'MdFmt: buffer is not modifiable' | echohl None
    return
  endif
  if !executable('dprint')
    echohl WarningMsg | echomsg 'MdFmt: dprint not found in PATH' | echohl None
    return
  endif
  let l:old = getline(1, '$')
  let l:new = systemlist('dprint fmt --config-discovery=global --stdin md 2>/dev/null', l:old)
  if v:shell_error
    echohl ErrorMsg | echomsg 'MdFmt: dprint failed (' . v:shell_error . ')' | echohl None
    return
  endif
  if empty(l:new)
    echohl ErrorMsg | echomsg 'MdFmt: dprint returned no output' | echohl None
    return
  endif
  if l:new ==# l:old
    echomsg 'MdFmt: already formatted'
    return
  endif
  let l:view = winsaveview()
  call setline(1, l:new)
  if len(l:old) > len(l:new)
    silent execute 'undojoin | ' . (len(l:new) + 1) . ',$delete _'
  endif
  call winrestview(l:view)
  echomsg printf('MdFmt: %d -> %d lines', len(l:old), len(l:new))
endfunction
