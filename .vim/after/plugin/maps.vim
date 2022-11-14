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

nnoremap <leader>ö :split<CR>
nnoremap <leader>ü :vsplit<CR>


" there's a conflict with diffchar
nmap ]b <Plug>(unimpaired-bnext)
nmap [b <Plug>(unimpaired-bprevious)

nnoremap <leader>q :bd<cr> " quit buffer
nnoremap <leader>, :b#<cr> " alternate buffer

nnoremap <silent> K :call myfunctions#show_documentation()<CR>



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

inoremap jj <Esc>

" format paragraph
nnoremap <leader>q gqap
" clear search highlight TODO: might not need it anymore
nnoremap <silent> <leader>m :noh <bar> call popup_clear()<cr>


nmap <leader>vr :source ~/.vim/vimrc<cr>

" Allow gf to open non-existent files
map gf :edit <cfile><cr>

" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv


"wrap
nnoremap <leader>w :set wrap!<cr>

" this also has a sideeffect of Q NOT taking you to ex mode
nnoremap Q :wqa<CR>
" this shadowd dl but who uses that anyway?
nnoremap X :qa!<CR>

" jk will work visually except when taking a count
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
inoremap <silent> <Up> <ESC><Up>
inoremap <silent> <Down> <ESC><Down>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

" imap <C-i> <Esc>saiW_Wi
" imap <C-b> <Esc>saiW*.Whi
" most editors will have these for bold and italic
imap <C-e> <Esc>saiW_Wa
imap <C-b> <Esc>saiW*.Wa

nnoremap <F2> :CocToggle<CR>
nnoremap <F3> :ALEToggle<CR>
nnoremap <F4> :AutoSaveToggle<CR>
nnoremap <F5> :setlocal spell! spelllang=en_gb,hu<CR>
nnoremap <F6> :GundoToggle<CR>
nnoremap <F7> :NERDTreeToggle<CR>
nnoremap <F8> :TagbarToggle<CR>

" spelling
nnoremap zó 1z=

" Ctrl-c copies to system keyboard in visual
vmap <C-C> "+y
nnoremap Y yg_
vnoremap Y <esc>:'<,'>:w !curl -LSsF file=@- https://0x0.st<CR>
" nnoremap F gqap
" vnoremap F gq



" Ctrl-p pastes the last yank: vim unimpaired may have better maps
nnoremap <leader>p "0p
nnoremap <leader>P "0P
" nnoremap <leader>v "+p
nnoremap <leader>d "_dd
nnoremap <leader>o o<ESC>"+P
" nnoremap <leader>gp "0gp
" nnoremap <leader>gv "+gp
" Maintain the cursor position when yanking a visual selection
" http://ddrscott.github.io/blog/2016/yank-without-jank/
" vnoremap <expr>y "my\"" . v:register . "y`y"
" vnoremap <expr>Y "mY\"" . v:register . "Y`Y"
