Plug 'christoomey/vim-tmux-navigator'

let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-h> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :<C-U>TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :<C-U>TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :<C-U>TmuxNavigateRight<cr>
nnoremap <silent> <C-,> :<C-U><C-U>TmuxNavigatePrevious<cr>

vnoremap <silent> <C-h> :<C-U>TmuxNavigateLeft<cr>gv
vnoremap <silent> <C-j> :<C-U>TmuxNavigateDown<cr>gv
vnoremap <silent> <C-k> :<C-U>TmuxNavigateUp<cr>gv
vnoremap <silent> <C-l> :<C-U>TmuxNavigateRight<cr>gv
vnoremap <silent> <C-,> :<C-U>TmuxNavigatePrevious<cr>gv

if !empty($TMUX)
  function! IsFZF() abort
    return &ft ==# 'fzf'
  endfunction
  tnoremap <expr> <silent> <C-h> IsFZF() ? "\<C-h>" : "\<C-\>\<C-n>:\<C-U>TmuxNavigateLeft\<cr>"
  tnoremap <expr> <silent> <C-j> IsFZF() ? "\<C-j>" : "\<C-\>\<C-n>:\<C-U>TmuxNavigateDown\<cr>"
  tnoremap <expr> <silent> <C-k> IsFZF() ? "\<C-k>" : "\<C-\>\<C-n>:\<C-U>TmuxNavigateUp\<cr>"
  tnoremap <expr> <silent> <C-l> IsFZF() ? "\<C-l>" : "\<C-\>\<C-n>:\<C-U>TmuxNavigateRight\<cr>"
endif
