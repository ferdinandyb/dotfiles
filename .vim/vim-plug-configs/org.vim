Plug 'vimwiki/vimwiki'
Plug 'michal-h21/vim-zettel'
Plug 'tools-life/taskwiki'
Plug 'ferdinandyb/bibtexcite.vim'

let g:bibtexcite_bibfile = $HOME . "/org/zotero.bib"
let g:bibtexcite_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
let g:bibtexcite_openfilecommand = 'zathura'


let g:vimwiki_list = [{
      \ 'path': '~/org/',
      \ 'syntax': 'markdown',
      \ 'ext': '.md',
      \ 'diary_frequency':'weekly',
      \ 'auto_diary_index':1,
      \ 'links_space_char': '_',
      \ 'auto_tags': 1,
      \ 'auto_generate_links': 1,
      \ 'auto_generate_tags': 1,
      \}]
let g:vimwiki_global_ext = 0
let g:vimwiki_markdown_link_ext = 1
let g:vimwiki_dir_link = '' " this is the default, but maybe 'index' would be better
let g:vimwiki_key_mappings =
  \ {
  \   'all_maps': 1,
  \   'global': 1,
  \   'headers': 1,
  \   'text_objs': 1,
  \   'table_format': 1,
  \   'table_mappings': 1,
  \   'lists': 1,
  \   'links': 0,
  \   'html': 0,
  \   'mouse': 0,
  \ }

" let g:vimwiki_filetypes = ['markdown', 'pandoc']


let g:zettel_options = [{'rel_path': 'zettel/'}]
