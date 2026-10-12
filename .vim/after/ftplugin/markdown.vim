nnoremap <buffer><silent> gf :call myfunctions#md_gf()<CR>
setlocal conceallevel=2
call myfunctions#prose_format_setup()

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
