Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
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

nmap <leader>y :FYadm!<CR>

nnoremap <leader>* :execute 'FRg ' . expand('<cword>')<CR>
