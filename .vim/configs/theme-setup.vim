" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'ferdinandyb/vim', { 'as': 'dracula' }
" Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/promptline.vim'
Plug 'edkolev/tmuxline.vim'
" just nice icons
Plug 'ryanoasis/vim-devicons'

let g:airline_theme = 'dracula'
let g:airline_powerline_fonts = 1
let g:airline_skip_empty_sections = 1

let g:airline_left_sep = ''
let g:airline_right_sep = ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline_detect_spell=1
let g:airline_detect_spelllang=1
let g:airline_experimental=1



let g:promptline_theme = 'airline'

autocmd User PlugLoaded ++nested let g:promptline_preset = {
    \'b' : [ '$(if [[ -n "$SSH_CLIENT" ]]; then echo $USER; fi;)' ],
    \'c' : [ promptline#slices#cwd() ],
    \'a' : [ promptline#slices#vcs_branch(), promptline#slices#python_virtualenv() ],
    \'warn' : [ promptline#slices#last_exit_code() ]}

" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = ' '


" sets the title to the open buffer, useful for tmux pane search
set title
set titlestring=VIM:\ %(%m%)%(%{expand(\"%:~\")}%)
" powerline
" set rtp+=$HOME/.local/lib/python3.8/site-packages/powerline/bindings/vim/

" Always show statusline
set laststatus=2
" set showtabline=2
set noshowmode

" this is needed for kitty background to work properly
let &t_ut=''

autocmd User PlugLoaded ++nested colorscheme dracula


