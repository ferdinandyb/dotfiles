Plug 'voldikss/vim-floaterm'


let g:floaterm_width = 0.99
let g:floaterm_height = 0.99

nnoremap <A-t> <cmd>FloatermHide!<cr>
tnoremap <A-t> <C-\><C-n><cmd>FloatermHide!<cr>

function! s:ToggleFloatermWindow(name, cmd, ...) abort
  if floaterm#terminal#get_bufnr(a:name) == -1
    let full_cmd = a:0 > 0 ? a:cmd . ' ' . join(a:000) : a:cmd
    execute 'FloatermNew --name=' . a:name . ' ' . full_cmd
  else
    execute 'FloatermToggle ' . a:name
  endif
endfunction

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
autocmd FileType floaterm nnoremap <buffer> <C-w>< <cmd>FloatermToggleWintype split<cr>
autocmd FileType floaterm nnoremap <buffer> <C-w>> <cmd>FloatermToggleWintype vsplit<cr>

command! Lazygit FloatermNew lazygit
command! Lazyjira FloatermNew lazyjira
command! LG FloatermNew lazygit

command! Mdterm FloatermNew mdterm %
nnoremap <leader> <cmd>Mdterm<cr>

command! -nargs=* Tuicr call s:ToggleFloatermWindow('tuicr', 'EDITOR=$FLOATERM tuicr', <f-args>)
nnoremap <A-u> <cmd>Tuicr<cr>
tnoremap <A-u> <C-\><C-n><cmd>Tuicr<cr>

command! -nargs=* OpencodeFloat call s:ToggleFloatermWindow('opencode','TMUX= STY= opencode --port 0', <f-args>)
nnoremap <A-o> <cmd>OpencodeFloat<cr>
tnoremap <A-o> <C-\><C-n><cmd>OpencodeFloat<cr>
