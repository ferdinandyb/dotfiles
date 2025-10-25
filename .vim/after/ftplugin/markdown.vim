nmap <buffer>gf <Plug>Markdown_EditUrlUnderCursor
set conceallevel=2
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_emphasis_multiline = 0
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_toml_frontmatter = 1

" https://github.com/preservim/vim-markdown/issues/232
" setlocal comments=b:*,b:+,b:-,b:>
setlocal formatoptions-=q
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*\[-*+]\\s\\+

inoremap <buffer> <silent> [[ <Esc>:w<CR>:ZettelFind<CR>
nnoremap <buffer> <silent> <leader>nc :BibtexciteInsert<CR>
inoremap <buffer> <silent> @@ <Esc>:BibtexciteInsert<CR>

let b:auto_save_events = ["WinLeave","BufLeave","CursorHold","CursorHoldI"]


function! VisualCodeBlock()
  call search('```', 'b')
  normal! j0v
  call search('```')
  normal! k$
endfunction

vnoremap iq <Cmd>call VisualCodeBlock()<CR>
omap iq :normal Viq<CR>
