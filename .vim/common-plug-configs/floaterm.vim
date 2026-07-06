Plug 'voldikss/vim-floaterm'

command! Lazygit FloatermNew lazygit
command! Lazyjira FloatermNew lazyjira
command! Tuicr FloatermNew tuicr
command! LG FloatermNew lazygit
command! Mdterm FloatermNew mdterm %

function! s:ToggleFloatermWintype(target) abort
  " FloatermUpdate reuses whatever's already stored for any field not passed
  " explicitly (doesn't re-derive from g:floaterm_*), so every dimension must
  " be passed on every transition or a stale value leaks into the next one.
  let current = get(b:, 'floaterm_wintype', 'float')
  if current ==# a:target
    execute 'FloatermUpdate --wintype=float --width=' . g:floaterm_width
          \ . ' --height=' . g:floaterm_height
          \ . ' --position=' . g:floaterm_position
  elseif a:target ==# 'split'
    FloatermUpdate --wintype=split --width=0.99 --height=0.5
  elseif a:target ==# 'vsplit'
    FloatermUpdate --wintype=vsplit --width=0.5 --height=0.99
  endif
  " :split/:vsplit inherit number/list from whatever window they're created
  " from (unlike float) -- reset explicitly or a code buffer's settings leak in.
  setlocal nonumber norelativenumber nolist
endfunction
command! -nargs=1 FloatermToggleWintype call s:ToggleFloatermWintype(<f-args>)
" Buffer-local override of maps.vim's <C-w>ö/<C-w>ü: toggle wintype here
" instead of splitting. Normal-mode only -- leave terminal-mode first.
autocmd FileType floaterm nnoremap <buffer> <C-w>ö <cmd>FloatermToggleWintype split<cr>
autocmd FileType floaterm nnoremap <buffer> <C-w>ü <cmd>FloatermToggleWintype vsplit<cr>

let g:floaterm_width = 0.99
let g:floaterm_height = 0.99
