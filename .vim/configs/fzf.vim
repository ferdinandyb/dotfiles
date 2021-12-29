Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'

let g:fzf_command_prefix = 'Fzf'
nnoremap <leader>fg :FzfGitFiles<cr>
nnoremap <leader>ft :FzfTags<cr>
nnoremap <leader>fr :FzfRg<space>
nnoremap <leader>fm :FzfMarks<cr>
nnoremap <leader>fl :FzfLines<cr>
nnoremap <leader>fw :FzfWindows<cr>
nnoremap <leader>fc :call vimtex#fzf#run()<cr>
nnoremap <leader>F :FzfFiles<cr>
nnoremap <leader>f :FzfAllFiles<cr>
nnoremap <leader>b :FzfBuffers<cr>
nnoremap <leader>: :FzfHistory<cr>
nnoremap <leader>é :FzfHistory<cr>
nnoremap <leader>/ :FzfHistory/<cr>
nnoremap <leader>gb :FzfGBranches<cr>

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit',
  \ 'ctrl-o': ':r !echo'}


let g:fzf_layout = { 'up': '~90%', 'window': { 'width': 0.8, 'height': 0.8, 'yoffset':0.5, 'xoffset': 0.5 } }
let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline'

" Customise the Files command to use rg which respects .gitignore files
command! -bang -nargs=? -complete=dir FzfFiles
            \ call fzf#run(fzf#wrap('files',
            \ fzf#vim#with_preview({
            \ 'dir': <q-args>,
            \ 'sink': 'e', 'source': 'rg --files --hidden' }), <bang>0))

" Add an AllFiles variation that ignores .gitignore files
command! -bang -nargs=? -complete=dir FzfAllFiles
            \ call fzf#run(fzf#wrap('allfiles',
            \ fzf#vim#with_preview(
            \ { 'dir': <q-args>,
            \ 'sink': 'e', 'source': 'rg --files --hidden --no-ignore' }),
            \ <bang>0))

" a command to search for files managed by yadm
command! -bang -nargs=? -complete=dir FzfYadm
            \ call fzf#run(fzf#wrap('allfiles',
            \ fzf#vim#with_preview(
            \ { 'dir': <q-args>,
            \ 'sink': 'e', 'source': 'yadmlistall' }), <bang>0))
