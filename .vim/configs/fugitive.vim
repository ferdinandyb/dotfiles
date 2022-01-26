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
Plug 'airblade/vim-gitgutter'

let g:twiggy_close_on_fugitive_command = 1
let g:twiggy_split_position = 'topleft'
