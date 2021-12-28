" ##### GIT #######
" git integration from tpope 
" (as commandline but :G instead of git, % is current file)
Plug 'tpope/vim-fugitive'
" bitbucket plugin for fugitive
Plug 'tommcdo/vim-fubitive'
Plug 'tpope/vim-rhubarb'
" fugitive plugin for branch management
Plug 'sodapopcan/vim-twiggy'
" commit browser plugin for fugitive
Plug 'junegunn/gv.vim'
" if has('nvim') || has('patch-8.0.902')
"   Plug 'mhinz/vim-signify'
" else
"   Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
" endif
Plug 'airblade/vim-gitgutter'

let g:twiggy_close_on_fugitive_command = 1
let g:twiggy_split_position = 'topleft'

autocmd User SignifyHunk call s:show_current_hunk()

function! s:show_current_hunk() abort
  let h = sy#util#get_hunk_stats()
  if !empty(h)
    echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
  endif
endfunction
nnoremap <leader>sd :SignifyDiff<cr>
nnoremap <leader>sp :SignifyHunkDiff<cr>
nnoremap <leader>su :SignifyHunkUndo<cr>


autocmd User FugitiveIndex nmap <buffer> ö =

