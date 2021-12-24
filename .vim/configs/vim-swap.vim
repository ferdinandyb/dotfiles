Plug 'machakann/vim-swap'
" g< and g> on English
nmap gü <Plug>(swap-prev)
nmap gó <Plug>(swap-next)

" vim swap text objects 
omap i, <Plug>(swap-textobject-i)
xmap i, <Plug>(swap-textobject-i)
omap a, <Plug>(swap-textobject-a)
xmap a, <Plug>(swap-textobject-a)

