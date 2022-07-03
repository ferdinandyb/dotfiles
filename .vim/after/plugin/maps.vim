" Langmap is broken currently, see https://github.com/vim/vim/issues/3018


set langmap=\
            \ő[,
            \Ő{,
            \ú],
            \Ú},
            \é:,
            \á`,
            \ű',
            \ö<,
            \ü>,
            \ó=

nmap ő [
xmap ő [
omap ő [
nmap ú ]
omap ú ]
xmap ú ]
nmap Ő {
xmap Ő {
omap Ő {
nmap Ú }
omap Ú }
xmap Ú }

nmap ö <
nmap ü >
nmap ó =

" " you usually want to repeat in the same direction but altgr-, is complicated
" but it is handled by sneak now
" nnoremap , ;
" nnoremap ; ,

nnoremap <leader>ö :new<CR>
nnoremap <leader>ü :vnew<CR>


" there's a conflict with diffchar
nmap ]b <Plug>(unimpaired-bnext)
nmap [b <Plug>(unimpaired-bprevious)

nnoremap <leader>q :bd<cr> " quit buffer
nnoremap <leader>, :b#<cr> " alternate buffer

nnoremap <silent> K :call myfunctions#show_documentation()<CR>


nnoremap gs :Git<CR>

nnoremap <leader>g :FGitFiles!<cr>
nnoremap <leader>ft :FTags!<cr>
nnoremap <leader>fr :FRg<space>
nnoremap <leader>fm :FMarks!<cr>
nnoremap <leader>fl :FLines!<cr>
nnoremap <leader>fw :FWindows!<cr>
nnoremap <leader>fc :call vimtex#fzf#run()<cr>
nnoremap <leader>f :FFiles!<cr>
nnoremap <leader>F :FAllFiles!<cr>
nnoremap <leader>b :FBuffers!<cr>
nnoremap <leader>: :FHistory!<cr>
nnoremap <leader>é :FHistory!<cr>
nnoremap <leader>/ :FHistory/!<cr>
nnoremap <leader>gb :FGBranches!<cr>


nnoremap <leader>ccn :CetliNew
nnoremap <leader>cn :FecniNew
nnoremap <leader>ccs :CetliSearch<CR>
nnoremap <leader>cs :FecniSearch<CR>
nnoremap <leader>ca :FecniSearchAll<CR>
nnoremap <leader>cb :BibtexciteInsert<CR>
nnoremap <leader>cg :Goyo<CR>

nnoremap <silent> s <nop>
nnoremap <silent> S <nop>

let g:textobj_sandwich_no_default_key_mappings = 1
xmap ib <Plug>(textobj-sandwich-auto-i)
omap ib <Plug>(textobj-sandwich-auto-i)
xmap ab <Plug>(textobj-sandwich-auto-a)
omap ab <Plug>(textobj-sandwich-auto-a)

xmap iq <Plug>(textobj-sandwich-query-i)
omap iq <Plug>(textobj-sandwich-query-i)
xmap aq <Plug>(textobj-sandwich-query-a)
omap aq <Plug>(textobj-sandwich-query-a)
