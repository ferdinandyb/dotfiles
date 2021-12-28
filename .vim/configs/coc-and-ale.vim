" LSP implementation
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
Plug 'dense-analysis/ale'

let g:coc_global_extensions = [
\ 'coc-json',
\ 'coc-vetur',
\ 'coc-pyright',
\ 'coc-snippets',
\ 'coc-tag',
\ 'coc-tsserver',
\ 'coc-tabnine']

let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []

let g:ale_disable_lsp = 1

let g:ale_linters = {
\   'javascript': ['eslint'],
\	'python': ['pylint', 'flake8']
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines','trim_whitespace'],
\   'python': ['black', 'isort']
\}

autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
" apply autofix to problem on the current line.
nmap <leader>cf  <plug>(coc-fix-current)
nmap <leader>cm  <plug>(coc-format-selected)
xmap <leader>cm  <plug>(coc-format-selected)
nmap <leader>cc  <Plug>(coc-codeaction)
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ga  <Plug>(coc-codeaction-line)


nmap <leader>co :CocFzfList outline <CR>
nmap <leader>cl :CocFzfList <CR>
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

nmap <leader>f <Plug>(ale_fix)
nmap <silent> <leader>j <Plug>(ale_next_wrap_error)
nmap <silent> <leader>k <Plug>(ale_previous_wrap_error)
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
let g:coc_snippet_prev = '<s-tab>'
let g:coc_snippet_next = '<tab>'
imap <C-y> <Plug>(coc-snippets-expand)

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction





" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
"

