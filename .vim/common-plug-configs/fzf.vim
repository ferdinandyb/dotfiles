Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'

let g:fzf_command_prefix = 'F'

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ö': 'split',
  \ 'ü': 'vsplit',
  \ 'ctrl-o': ':r !echo'}

" let g:fzf_action = { 'ctrl-r': function('s:insert_file_name')}

let g:fzf_layout = { 'up': '~90%', 'window': { 'width': 0.8, 'height': 0.8, 'yoffset':0.5, 'xoffset': 0.5 } }
let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline --bind "alt-a:select-all,alt-d:deselect-all"'

" Customise the Files command to use rg which respects .gitignore files
command! -bang -nargs=? -complete=dir FFiles
            \ call fzf#run(fzf#wrap('files',
            \ fzf#vim#with_preview({
            \ 'source': 'rg --files --hidden'}), <bang>0))

" " Add an AllFiles variation that ignores .gitignore files
command! -bang -nargs=? -complete=dir FAllFiles
            \ call fzf#run(fzf#wrap('allfiles',
            \ fzf#vim#with_preview(
            \ { 'dir': <q-args>,
            \ 'source': 'rg --files --hidden --no-ignore' }),
            \ <bang>0))

" a command to search for files managed by yadm
command! -bang -nargs=? -complete=dir FYadm
            \ call fzf#run(fzf#wrap('yadm',
            \ fzf#vim#with_preview(
            \ { 'dir': <q-args>,
            \ 'source': 'yadm list -a' }), <bang>0))

nmap <leader>fy :FYadm!<CR>

nnoremap <leader>* :execute 'FRg ' . expand('<cword>')<CR>


" Smart <C-]>: 1 match -> native jump; >1 matches -> fzf picker.
let s:fzf_tags_sink = v:null
function! s:smart_tags_sink(word, lines) abort
  if len(a:lines) >= 2
    call settagstack(winnr(), {'items':
      \ [{'tagname': a:word, 'from': [bufnr('%'), line('.'), col('.'), 0]}]}, 'a')
  endif
  if s:fzf_tags_sink is v:null
    " resolve the script-local sink's <SNR> id; cached after first jump
    let l:scr = getscriptinfo({'name': 'fzf\.vim/autoload/fzf/vim\.vim$'})
    let s:fzf_tags_sink = function('<SNR>' . l:scr[0].sid . '_tags_sink')
  endif
  call call(s:fzf_tags_sink, [a:lines])
endfunction

function! s:smart_tag_jump() abort
  let l:word = expand('<cword>')
  if empty(l:word) | return | endif
  let l:n = len(taglist('^' . l:word . '$'))
  if l:n == 0
    echohl ErrorMsg | echom 'E426: tag not found: ' . l:word | echohl None
  elseif l:n == 1
    execute "normal! \<C-]>"
  else
    call fzf#vim#tags(l:word, {'sink*': function('s:smart_tags_sink', [l:word])})
  endif
endfunction

nnoremap <silent> <C-]> :call <SID>smart_tag_jump()<CR>
