" need to have npm and yarn for markdown preview
Plug 'lervag/vimtex'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" required by vim-markdown but easy-align is probably better
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'junegunn/goyo.vim'
Plug 'alok/notational-fzf-vim'
Plug 'ferdinandyb/bibtexcite.vim'
Plug 'ferdinandyb/cetli.vim'
" Plug 'vim-pandoc/vim-pandoc'
" Plug 'vim-pandoc/vim-pandoc-syntax'

" These are overkill but good for inspiration

" Plug 'vimwiki/vimwiki'
" Plug 'michal-h21/vim-zettel'
" Plug 'michal-h21/vimwiki-sync'
" https://github.com/Aarleks/zettel.vim
" https://github.com/AndrewCopeland/zettelkasten"
"
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

let g:vim_markdown_math = 1
let g:vim_markdown_conceal = 2
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_frontmatter = 1
let g:nv_search_paths = ['~/cetlidoboz']



let g:bibtexcite_bibfile = $HOME . "/cetlidoboz/zotero.bib"
let g:bibtexcite_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']




let g:cetli_fzf_insert_link_ctrl='l'
let g:cetli_directory = $HOME . '/cetlidoboz/'
let g:cetli_date_format = "%Y-%m-%d %H:%M"
let g:cetli_filename_date_format = "%y%m%d%H%M"

