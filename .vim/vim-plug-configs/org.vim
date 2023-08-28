Plug 'vimwiki/vimwiki'
Plug 'michal-h21/vim-zettel'
Plug 'tools-life/taskwiki'
" Plug 'michal-h21/vimwiki-sync'
" https://github.com/Aarleks/zettel.vim
" https://github.com/AndrewCopeland/zettelkasten"
"
Plug 'ferdinandyb/bibtexcite.vim'
Plug 'ferdinandyb/cetli.vim'

let g:bibtexcite_bibfile = $HOME . "/org/zotero.bib"
let g:bibtexcite_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
let g:bibtexcite_openfilecommand = 'zathura'

"

let g:vimwiki_list = [{'path':'~/testwiki'},{'path': '~/org/', 'syntax': 'markdown', 'ext': '.md', 'diary_frequency':'weekly', 'auto_diary_index':1}]
" let g:vimwiki_list = [{'path': '~/org/', 'syntax': 'markdown', 'ext': '.md', 'diary_frequency':'weekly', 'auto_diary_index':1}]
let g:zettel_options = [{},{'rel_path': 'zettel/'}]

"
"cetli


let g:cetli_configuration = [
            \ {"path": $HOME . '/org/cetlidoboz', "prefix": "Cetli", "default_type": "cetli", "naming": "time" },
            \ {"path": $HOME . '/org/fecnidoboz', "prefix": "Fecni", "default_type": "fleeting", "naming": "time" },
            \ {"path": $HOME . '/org/resources', "prefix": "Resource", "default_type": "resource", "naming": "time" },
            \ {"path": $HOME . '/org/INBOX', "prefix": "Inbox", "default_type": "inbox", "naming": "time" },
            \ {"path": $HOME . '/org/agendas', "prefix": "Agenda", "default_type": "agenda", "naming": "manual" },
            \ {"path": $HOME . '/org/projects', "prefix": "Project", "default_type": "project", "naming": "manual" }
            \ ]

let g:cetli_searchall_prefix = "Org"
let g:cetli_searchall_executedir = $HOME . '/org'


let g:cetli_fzf_insert_link_ctrl='e'
let g:cetli_date_format = "%Y-%m-%d %H:%M %A"
let g:cetli_filename_date_format = "%y%m%d%H%M"

augroup cetli_autogroup
    au!
    au BufRead ~/org/** let b:auto_save = 1
augroup END
