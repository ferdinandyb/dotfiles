Plug 'lervag/vimtex'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" required by vim-markdown but easy-align is probably better
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'junegunn/goyo.vim'
Plug 'alok/notational-fzf-vim'

" These are overkill but good for inspiration

" Plug 'vimwiki/vimwiki'
" Plug 'michal-h21/vim-zettel'
" Plug 'michal-h21/vimwiki-sync'
" https://github.com/Aarleks/zettel.vim
" https://github.com/AndrewCopeland/zettelkasten"

let g:vim_markdown_math = 1
let g:vim_markdown_conceal = 2
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_frontmatter = 1
let g:nv_search_paths = ['~/zettelkasten']

let $FZF_BIBTEX_CACHEDIR = $HOME . '/.cache/bibtex_fzf'
let $FZF_BIBTEX_SOURCES = $HOME . '/zettelkasten/zotero.bib'

function! s:bibtex_cite_sink(lines)
    let r=system("bibtex-cite ", a:lines)
    execute ':normal! a' . r
endfunction

function! s:bibtex_markdown_sink(lines)
    let r=system("bibtex-markdown ", a:lines)
    execute ':normal! a' . r
endfunction

autocmd FileType markdown  nnoremap <buffer>  <silent> <leader>i :call fzf#run({
    \ 'source': 'bibtex-ls',
    \ 'sink*': function('<sid>bibtex_cite_sink'),
    \ 'up': '40%',
    \ 'options': '--ansi --layout=reverse-list --multi --prompt "Cite> "'})<CR>

" autocmd FileType markdown  nnoremap <buffer>  <silent> <leader>cm :call fzf#run({
"     \ 'source': 'bibtex-ls',
"     \ 'sink*': function('<sid>bibtex_markdown_sink'),
"     \ 'up': '40%',
"     \ 'options': '--ansi --layout=reverse-list --multi --prompt "Markdown> "'})<CR>

let g:zettel_directory = $HOME . '/zettelkasten/'
let g:zettel_date_format = "%Y-%m-%d %H:%M"
let g:zettel_filename_date_format = "%y%m%d%H%M"

function! s:count_files(pattern)
  let filelist = split(globpath(g:zettel_directory, a:pattern), '\n')
  return len(filelist)
endfunction


let s:letters = "abcdefghijklmnopqrstuvwxyz"

" convert number to str (1 -> a, 27 -> aa)
function! s:numtoletter(num)
    if (a:num == 0)
        return ""
    endif
    let numletter = strlen(s:letters)
    let charindex = a:num % numletter
    let quotient = a:num / numletter
    if (charindex-1 == -1)
      let charindex = numletter
      let quotient = quotient - 1
    endif

    let result =  strpart(s:letters, charindex - 1, 1)
    if (quotient>=1)
      return <sid>numtoletter(float2nr(quotient)) . result
    endif
    return result
endfunction

function! s:date_to_name(date)
   return a:date
endfunction


function! s:zettel_new(...)

    let zettel_date = strftime(g:zettel_date_format)
    let filename = strptime(g:zettel_date_format,zettel_date)
    let filename = strftime(g:zettel_filename_date_format,filename)
    let file_count = <sid>count_files(filename . '*.md')
    let filename = filename . <sid>numtoletter(file_count) . ".md"
    let filename = g:zettel_directory . filename
    echom a:0
    echom a:1
    if (a:0 > 0)
        let zettel_title = a:1
    else
        let zettel_title = ''
    endif

    let lines = [ '---',
                \ 'title: ' . zettel_title,
                \ 'date: ' . zettel_date,
                \ 'tags:',
                \ '---' ]
    execute "e " filename
    call append(0, lines)

endfunction

command! -bang -nargs=? ZettelNew call <sid>zettel_new(<q-args>)

