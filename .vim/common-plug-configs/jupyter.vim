Plug 'untitled-ai/jupyter_ascending.vim'
Plug 'goerz/jupytext.vim'

" disable the jupyter-vim bindings
let g:jupyter_mapkeys = 0

nnoremap <Leader>x <Plug>JupyterExecute
nnoremap <Leader>X <Plug>JupyterExecuteAll
nmap <Leader>R <Plug>JupyterRestartAndExecuteAll
let g:jupyter_ascending_match_pattern=".sync.py"
