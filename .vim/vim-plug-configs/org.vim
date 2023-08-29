Plug 'vimwiki/vimwiki'
Plug 'michal-h21/vim-zettel'
Plug 'tools-life/taskwiki'
Plug 'ferdinandyb/bibtexcite.vim'

let g:bibtexcite_bibfile = $HOME . "/org/zotero.bib"
let g:bibtexcite_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
let g:bibtexcite_openfilecommand = 'zathura'


let g:vimwiki_list = [{'path': '~/org/', 'syntax': 'markdown', 'ext': '.md', 'diary_frequency':'weekly', 'auto_diary_index':1}]
let g:zettel_options = [{'rel_path': 'zettel/'}]
