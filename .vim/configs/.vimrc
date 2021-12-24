if empty(glob('~/.vim/autoload/plug.vim'))
	  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif



let mapleader = "\<space>"
let maplocalleader = "\<space>"

call plug#begin('~/.vim/plugged')
" install language packs, but disable any you hand tweak
source ~/.vim/vimrc/theme_setup.vim
Plug 'sheerun/vim-polyglot'
source ~/.vim/vimrc/vim-polyglot.vim
" just nice icons
Plug 'ryanoasis/vim-devicons'
" extended %
Plug 'andymass/vim-matchup'
" add new targets to vim eg c2i)
Plug 'wellle/targets.vim'
" adds xml/html text objects
Plug 'kana/vim-textobj-user' | Plug 'whatyouhide/vim-textobj-xmlattr'
" allows seemles navigation of vim and tmux splits, kitty vim tmux probably is
" better?
" Plug 'christoomey/vim-tmux-navigator'
" tmux config syntax highlight
Plug 'whatyouhide/vim-tmux-syntax'
" syntax and navigator for kitty
Plug 'fladson/vim-kitty'
Plug 'NikoKS/kitty-vim-tmux-navigator'

" command to align text (never used it yet, learn or remove)
source ~/.vim/vimrc/vim-easy-align.vim
" make path also when writing a new file with
Plug 'jessarcher/vim-heritage'
" open files at the last edit with some smart settings
Plug 'farmergreg/vim-lastplace'
" better surrounds than tpope's
Plug 'machakann/vim-sandwich'
" swap delimited items
source ~/.vim/vimrc/vim-swap.vim
" register viewing
Plug 'junegunn/vim-peekaboo'
source ~/.vim/vimrc/fugitive.vim
" should be coloring changes by char, but messes up colorscheme
" Plug 'rickhowe/diffchar.vim'
Plug 'ferdinandyb/diffchar.vim'

" n_ctrl-x/a work as expected for dates, roman numerals etc.
Plug 'tpope/vim-speeddating'
" makes speeddating repeatable
Plug 'tpope/vim-repeat'
source ~/.vim/vimrc/vim-obsession.vim
" simple comment facilities
Plug 'tpope/vim-commentary'
" file browser
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
source ~/.vim/vimrc/vim-auto-save.vim

Plug 'honza/vim-snippets'

source ~/.vim/vimrc/fzf.vim

" generate tags for jumping between latex tags and others
" requires https://askubuntu.com/questions/796408/installing-and-using-universal-ctags-instead-of-exuberant-ctags
Plug 'ludovicchabant/vim-gutentags'
Plug 'preservim/tagbar'
" clears searches smarter
Plug 'junegunn/vim-slash'
" visualize undo trees
Plug 'sjl/gundo.vim'
" doesn't open misspelled files
Plug 'einfachtoll/didyoumean'
" did you mean will use fzf
let g:dym_use_fzf = 1
" dispatch commands in the background
source ~/.vim/vimrc/dispatch.vim
Plug 'tpope/vim-unimpaired'
" wrap unix commands
Plug 'tpope/vim-eunuch'
" asynchronous linting
source ~/.vim/vimrc/coc-and-ale.vim
" switch between multiple lines and single lines
Plug 'AndrewRadev/splitjoin.vim'
" highlights letter for f,t, and co.
Plug 'unblevable/quick-scope'
Plug 'nanotee/zoxide.vim'
" auto switch to root dir
Plug 'airblade/vim-rooter'
let g:rooter_change_directory_for_non_project_files = 'current'
" let g:rooter_cd_cmd = 'Z'
"
" the below plugins are support for languages
"
" Emmet is for expanding html stuff
Plug 'mattn/emmet-vim'
Plug 'lervag/vimtex'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" required by vim-markdown but easy-align is probably better
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'pangloss/vim-javascript'
Plug 'othree/html5.vim'
Plug 'elzr/vim-json'
Plug 'jupyter-vim/jupyter-vim'
" PYTHON
" python syntax
Plug 'vim-python/python-syntax'
" python code folding
Plug 'tmhedberg/SimpylFold'
" python textobjects
Plug 'jeetsukumaran/vim-pythonsense'

call plug#end()
colorscheme dracula

function! Config_indicator()
    return "hello world"
endfunction

call airline#parts#define_function('config_indicator', 'Config_indicator')

let g:airline_section_y = airline#section#create_right(['ffenc','config_indicator'])
source ~/.vim/vimrc/settings.vim

" US keyboard layout like maps for HUN keyboard
source ~/.vim/vimrc/hunmap.vim

" buffers
noremap <leader>d :bd<cr> " quit buffer
noremap <leader>, :b#<cr> " alternate buffer

" better escape and exiting when using arrows
inoremap jk <Esc>
inoremap <silent> <Up> <ESC><Up>
inoremap <silent> <Down> <ESC><Down>

" format paragraph
nnoremap <leader>q gqap

" Map the <Space> key to toggle a selected fold opened/closed.
nnoremap <silent> Í @=(foldlevel('.')?'za':"\<Space>")<CR>
" vnoremap <Space>< zf

" Automatically save and load folds
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview"
" ros setup
autocmd BufRead,BufNewFile *.launch setfiletype roslaunch

" Rmarkdown
autocmd BufRead,BufNewFile *.Rmd setfiletype markdown

let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
let g:qs_max_chars=150


" this disable the jupyter-vim bindings
let g:jupyter_mapkeys = 0

" python-syntax highlightsetting
let g:python_highlight_all = 1
" run :PlugInstall to install stuff
" need to have npm and yarn for markdown preview

let g:vim_markdown_math = 1
let g:vim_markdown_conceal_code_blocks = 0
" let g:vim_markdown_strikethrough = 1
let g:vim_markdown_new_list_item_indent = 2

" emmet might be absolutely useless and just use snippets?
let g:user_emmet_install_global = 0
autocmd FileType html,css,vue EmmetInstall






let g:gundo_prefer_python3 = 1

" clear search highlight TODO: might not need it anymore
if has("nvim")
    nnoremap <silent> <leader>m :noh
else
    nnoremap <silent> <leader>m :noh <bar> call popup_clear()<cr>
endif



nmap <leader>vr :source ~/.vimrc<cr>

" Allow gf to open non-existent files
map gf :edit <cfile><cr>

" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" Maintain the cursor position when yanking a visual selection
" http://ddrscott.github.io/blog/2016/yank-without-jank/
vnoremap <expr>y "my\"" . v:register . "y`y"
vnoremap <expr>Y "mY\"" . v:register . "Y`Y"

"wrap
nnoremap <leader>w :set wrap!<cr>

" this also has a sideeffect of Q NOT taking you to ex mode
nnoremap Q :qa<CR>

" jk will work visually except when taking a count
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

" " imap <C-i> <Esc>saiW_Wi
" " imap <C-b> <Esc>saiW*.Whi
" " most editors will have these for bold and italic
inoremap <C-b> <C-o>:normal saiW_W<cr>

nnoremap <F3> :ALEToggle<CR>
nnoremap <F4> :AutoSaveToggle<CR>
nnoremap <F5> :setlocal spell! spelllang=en_gb,hu<CR>
nnoremap <F6> :GundoToggle<CR>
nmap <F8> :TagbarToggle<CR>

" spelling
nnoremap zz z=
nnoremap <leader>z 1z=

" Ctrl-c copies to system keyboard in visual
vmap <C-C> "+y


" Ctrl-p pastes the last yank
nnoremap <leader>p "0p
nnoremap <leader>v "+p
nnoremap <leader>d "_dd
nnoremap <leader>o o<ESC>"+P
nnoremap <leader>gp "0gp
nnoremap <leader>gv "+gp


" json
let g:vim_json_syntax_conceal = 0

" nerdtree mapping to ctrl n
nnoremap <silent> <C-n> :NERDTreeToggle<CR>



" vimtex setup
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_fold_enabled = 1
" let g:vimtex_quickfix_mode=0
" set conceallevel=1
" let g:tex_conceal='abdmg'

" usage of vimtex
" - need to start vim with `vim --servername vim`: should add alias
" - run :VimtexCompile to start compilation

" au FileType python exe "normal zR"

set nofoldenable
" set some marks in vue files for easy navigation
au FileType vue silent! call s:set_vue_marks()
function! s:set_vue_marks()
    if search("data()","w")
        mark d
    endif
    if search("methods:","w")
        mark m
    endif
    if search("mounted()","w")
        mark l
    endif
endfunction

augroup javascript_folding
    au!
    au FileType javascript setlocal foldmethod=syntax
augroup END
augroup vue
    au!
    au FileType vue setlocal foldmethod=expr
augroup END
