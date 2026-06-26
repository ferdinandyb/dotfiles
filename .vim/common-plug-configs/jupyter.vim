Plug 'untitled-ai/jupyter_ascending.vim'
Plug 'goerz/jupytext.vim'

" disable the jupyter-vim bindings
let g:jupyter_mapkeys = 0

augroup jupyter_ascending_maps
  autocmd!
  autocmd FileType python nmap <buffer> <leader>jx <Plug>JupyterExecute
  autocmd FileType python nmap <buffer> <leader>jX <Plug>JupyterExecuteAll
  autocmd FileType python nmap <buffer> <leader>jr <Plug>JupyterRestart
augroup END
let g:jupyter_ascending_match_pattern=".sync.py"
