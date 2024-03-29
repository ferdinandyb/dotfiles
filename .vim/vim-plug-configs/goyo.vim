Plug 'junegunn/goyo.vim'

function! s:goyo_enter()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif
  if !exists("g:lightweight")
    CocDisable
    ALEDisable
  endif
  " set noshowmode
  " set noshowcmd
  " set scrolloff=999
  " ...
endfunction

function! s:goyo_leave()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif
  " set showmode
  " set showcmd
  " set scrolloff=5
  " ...
  if !exists("g:lightweight")
    CocEnable
    ALEEnable
  endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
