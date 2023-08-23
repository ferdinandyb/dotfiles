" ##### GIT #######
" git integration from tpope
" (as commandline but :G instead of git, % is current file)
Plug 'tpope/vim-fugitive'
" bitbucket plugin for fugitive
Plug 'tommcdo/vim-fubitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'tpope/vim-rhubarb'
Plug 'https://git.sr.ht/~willdurand/srht.vim'

" fugitive plugin for branch management
Plug 'sodapopcan/vim-twiggy'
" commit browser plugin for fugitive
" Plug 'junegunn/gv.vim'
" alternate commit browser
Plug 'rbong/vim-flog'
Plug 'airblade/vim-gitgutter'

let g:twiggy_close_on_fugitive_command = 1
let g:twiggy_split_position = 'topleft'

let g:fugitive_gitlab_oldstyle_urls = 1
let g:fugitive_gitlab_domains = ['https://gitlab.org','https://mrbd15.pgsm.hu']
if !empty(glob(expand('~/.config/glab-cli/token')))
  let g:gitlab_api_keys = {'mrbd15.pgsm.hu': readfile(expand('~/.config/glab-cli/token'))[0]}
endif

nnoremap <leader>gd :Gvdiff<CR>
nnoremap gs :Git<CR>
nnoremap gS :vert Git<CR>
nnoremap <Leader>Gb :.GBrowse!<CR>
xnoremap <Leader>Gb :'<'>GBrowse!<CR>

" fugitive 3way split:
" obtain hunk: d2o ours, d3o theirs
" Plug 'seanbreckenridge/yadm-git.vim'"
" let g:yadm_git_enabled = 1
" let g:yadm_git_verbose = 0

" let g:yadm_git_fugitive_enabled = 1
" let g:yadm_git_gitgutter_enabled = 1

" let g:yadm_git_repo_path = "~/.local/share/yadm/repo.git"
" let g:yadm_git_default_git_path = "git""
