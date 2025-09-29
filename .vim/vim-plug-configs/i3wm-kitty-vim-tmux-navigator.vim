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
