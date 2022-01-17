nmap <buffer>gf <Plug>Markdown_EditUrlUnderCursor
set conceallevel=2
let g:vim_markdown_folding_disabled = 1
inoremap <buffer> <silent> [[ <Esc>:w<CR>:ZettelFind<CR>
nnoremap <buffer> <silent> <leader>nc :BibtexciteInsert<CR>
inoremap <buffer> <silent> @@ <Esc>:BibtexciteInsert<CR>
