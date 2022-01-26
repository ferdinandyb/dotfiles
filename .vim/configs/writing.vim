" need to have npm and yarn for markdown preview
Plug 'lervag/vimtex'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" required by vim-markdown but easy-align is probably better
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'alok/notational-fzf-vim'
Plug 'ferdinandyb/bibtexcite.vim'
Plug 'ferdinandyb/cetli.vim'
Plug 'vim-scripts/loremipsum'
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
let g:nv_search_paths = ['~/org/cetlidoboz','~/org/fecnidoboz', '~/org/projects', '~/org/meetings']



let g:bibtexcite_bibfile = $HOME . "/org/zotero.bib"
let g:bibtexcite_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']

let g:cetli_configuration = [
            \ {"path": $HOME . '/org/cetlidoboz', "prefix": "Cetli", "default_type": "cetli", "naming": "time" },
            \ {"path": $HOME . '/org/fecnidoboz', "prefix": "Fecni", "default_type": "fleeting", "naming": "time" },
            \ {"path": $HOME . '/org/meetings', "prefix": "Meeting", "default_type": "meeting", "naming": "time" },
            \ {"path": $HOME . '/org/agendas', "prefix": "Agenda", "default_type": "agenda", "naming": "manual" },
            \ {"path": $HOME . '/org/projects', "prefix": "Project", "default_type": "project", "naming": "manual" }
            \ ]

let g:cetli_searchall_prefix = "Org"
let g:cetli_searchall_executedir = $HOME . '/org'


let g:cetli_fzf_insert_link_ctrl='l'
let g:cetli_date_format = "%Y-%m-%d %H:%M %A"
let g:cetli_filename_date_format = "%y%m%d%H%M"

augroup cetli_autogroup
    au!
    au BufRead ~/org/** let b:auto_save = 1
    autocmd BufRead ~/org/** execute "GitGutterBufferDisable"
    " autocmd BufWrite ~/org/** !git add <afile> && git commit --all -m "Autocommit"
    autocmd BufWritePost ~/org/** silent! !git add <afile> && git commit --all -m 'Autocommit' 2> /dev/null 1>&2
    " autocmd BufWritePost ~/org/** execute "Dispatch git add % && git commit -m 'autocommit' 2> /dev/null 1>&2"

augroup END
