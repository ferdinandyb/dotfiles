" LSP implementation
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
" https://github.com/neoclide/coc.nvim/pull/3862
let s:cocextensions = [
    \ 'coc-json',
    \ 'coc-volar',
    \ 'coc-pyright',
    \ 'coc-snippets',
    \ 'coc-tag',
    \ 'coc-tsserver',
    \ 'coc-vimtex',
    \ 'coc-go',
    \ 'coc-texlab',
    \ 'coc-sourcekit',
    \ 'coc-sql',
    \ 'coc-db']

" if g:os == 'Android'
"     let g:coc_global_extensions = s:cocextensions
" else
"     let g:coc_global_extensions = s:cocextensions + ['coc-tabnine']
" endif

let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []
" let coc-config-notification-disabledProgressSources = * <- this is not
" working somehow


autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gz <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gR <Plug>(coc-plug-references-used)
" LSP namespace: coc actions under <leader>l* (go-to stays on gd/gy/gz/gr/gR above)
nmap <leader>lr <Plug>(coc-rename)
nmap <leader>lR <Plug>(coc-refactor)
" apply autofix to problem on the current line
nmap <leader>lx <Plug>(coc-fix-current)
nmap <leader>lf <Plug>(coc-format-selected)
xmap <leader>lf <Plug>(coc-format-selected)
nmap <leader>lc <Plug>(coc-codeaction)
" code action on a motion/selection, e.g. `<leader>laap` for the current paragraph
xmap <leader>la <Plug>(coc-codeaction-selected)
nmap <leader>la <Plug>(coc-codeaction-selected)
nmap <leader>lC <Plug>(coc-codeaction-line)

nmap <leader>lo :CocFzfList outline <CR>
nmap <leader>ll :CocFzfList <CR>

" Function/class text objects (vim only; neovim uses treesitter).
if !has('nvim')
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)
endif

inoremap <silent><expr> <C-z> coc#pum#visible() ? coc#pum#confirm() : (pumvisible() ? "\<C-y>" : "\<C-z>")


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
