" ##### GIT #######
" git integration from tpope
" (as commandline but :G instead of git, % is current file)
Plug 'tpope/vim-fugitive'
" bitbucket plugin for fugitive
Plug 'tommcdo/vim-fubitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'tpope/vim-rhubarb'

" fugitive plugin for branch management
Plug 'sodapopcan/vim-twiggy'
" commit browser plugin for fugitive
Plug 'junegunn/gv.vim'
" alternate commit browser
Plug 'rbong/vim-flog'
Plug 'airblade/vim-gitgutter'

let g:twiggy_close_on_fugitive_command = 1
let g:twiggy_split_position = 'topleft'
let g:fugitive_gitlab_domains = ['https://gitlab.formsense.com/']
" nnoremap <Leader>gy :.GBrowse!<CR>
" xnoremap <Leader>gy :'<'>GBrowse!<CR>
