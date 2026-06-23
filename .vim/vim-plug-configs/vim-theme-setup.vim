Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/promptline.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'ryanoasis/vim-devicons'

let g:airline_theme = 'dracula'
" let g:airline_theme = 'solarized'
let g:airline_powerline_fonts = 1
let g:airline_skip_empty_sections = 1

let g:airline_left_sep = ''
let g:airline_right_sep = ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#searchcount#enabled = 1
let g:airline_detect_spell=1
let g:airline_detect_spelllang=1
let g:airline_experimental=1

" tmuxline integration regenerates the tmux statusline on EVERY start (~15ms,
" profiled). Disable it; refresh the tmux bar manually with :TmuxlineSnapshot
" only when changing theme.
let g:airline#extensions#tmuxline#enabled = 0

let g:promptline_theme = 'airline'

autocmd User PlugLoaded ++nested let g:promptline_preset = {
    \'b' : [ '$(if [[ -n "$SSH_CLIENT" ]]; then echo $USER; fi;)' ],
    \'c' : [ promptline#slices#cwd() ],
    \'a' : [ promptline#slices#vcs_branch(), promptline#slices#python_virtualenv() ],
    \'warn' : [ promptline#slices#last_exit_code() ]}

" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = ' '
