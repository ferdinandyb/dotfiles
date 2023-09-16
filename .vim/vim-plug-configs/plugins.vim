Plug 'dstein64/vim-startuptime'
" dispatch commands in the background
Plug 'tpope/vim-dispatch'
" run tests with e.g. Dispatch
Plug 'vim-test/vim-test'
" database fun
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion'
" it is  in conflict with unimpaired so needs to be before
Plug 'rickhowe/diffchar.vim'
" extended %
Plug 'andymass/vim-matchup'
" add new targets to vim eg c2i)
Plug 'wellle/targets.vim'
" adds xml/html text objects
Plug 'kana/vim-textobj-user' | Plug 'whatyouhide/vim-textobj-xmlattr'
" tmux config syntax highlight
Plug 'whatyouhide/vim-tmux-syntax'
" syntax for kitty
Plug 'fladson/vim-kitty'
" command to align text (never used it yet, learn or remove)
" make path also when writing a new file with
Plug 'jessarcher/vim-heritage'
" open files at the last edit with some smart settings
Plug 'farmergreg/vim-lastplace'
" better surrounds than tpope's
Plug 'machakann/vim-sandwich'
" register viewing
Plug 'junegunn/vim-peekaboo'

" substitution for singular and plurals + changing the from snake_case to
" camelCase
Plug 'tpope/vim-abolish'

" auto expandtab setting
Plug 'tpope/vim-sleuth'


" n_ctrl-x/a work as expected for dates, roman numerals etc.
Plug 'tpope/vim-speeddating'
" makes speeddating repeatable
Plug 'tpope/vim-repeat'
" simple comment facilities
Plug 'tpope/vim-commentary'
" file browser
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-vinegar'

Plug 'honza/vim-snippets'


" generate tags for jumping between latex tags and others
" requires https://askubuntu.com/questions/796408/installing-and-using-universal-ctags-instead-of-exuberant-ctags
" clears searches smarter
Plug 'junegunn/vim-slash'
" visualize undo trees
Plug 'sjl/gundo.vim'


" doesn't open misspelled files
" Plug 'einfachtoll/didyoumean'
" let g:dym_use_fzf = 1
" did you mean will use fzf


" vim unimpaired might not be really needed ...
Plug 'tpope/vim-unimpaired'
" wrap unix commands
Plug 'tpope/vim-eunuch'
" asynchronous linting
" switch between multiple lines and single lines
Plug 'AndrewRadev/splitjoin.vim'

Plug 'nanotee/zoxide.vim'
" auto switch to root dir
" Plug 'airblade/vim-rooter'

Plug 'hauleth/vim-backscratch'

Plug 'pangloss/vim-javascript'
Plug 'othree/html5.vim'
Plug 'elzr/vim-json'
" Plug 'jpalardy/vim-slime', { 'for': 'python' }
" Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }"
" PYTHON
" python code folding
Plug 'tmhedberg/SimpylFold'
Plug 'jeetsukumaran/vim-pythonsense'

" python textobjects: isn't this covered by the LSP?
Plug 'Konfekt/FastFold'
Plug 'vim-scripts/LargeFile'
" Plug 'mhinz/vim-startify'
" let g:startify_custom_header = ''
"
Plug 'Fymyte/mbsync.vim'
