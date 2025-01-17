nmap <buffer>gf <Plug>Markdown_EditUrlUnderCursor
set conceallevel=2
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 0

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
