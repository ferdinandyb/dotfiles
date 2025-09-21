" Do no close buffers when opening new buffer on top
set hidden

set updatetime=750

" autoread to read stuff change outside of vim and the au to trigger it when
" moving around
set autoread
augroup Autoread
  autocmd!
  " Notify if file is changed outside of vim
  " Trigger `checktime` when files changes on disk
  " https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
  " https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
          \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
augroup END



" Wait less for keypresses and stuff?
set ttimeout
set ttimeoutlen=100

" show possibilities when using tab in command mode
set wildmenu
set wildmode=longest:full,full

" 007 will be 008 and not 010 on a ctrl-a
set nrformats-=octal
" Helps force plug-ins to load correctly when it is turned back on below.

" Turn off modelines (this is a security feature)
set modelines=0

" Automatically wrap text that extends beyond the screen length.
set wrap
" auto hard wrap when typing
" set textwidth=80
" set colorcolumn=+1
" this makes wrap not break words
set linebreak

" Uncomment below to set the max textwidth. Use a value corresponding to the width of your screen.
" set textwidth=79
set autoindent
set formatoptions=tcqrn1
set softtabstop=4
set shiftwidth=4
set expandtab

" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5
" Fixes common backspace problems
set backspace=indent,eol,start


" show command you are typing
set showcmd

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Display different types of white spaces.
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Show line numbers, but relative to current line
set number
set signcolumn=number "auto
set sidescroll=1

" Encoding
set encoding=utf-8

" Highlight matching search patterns
set hlsearch
" Enable incremental search
set incsearch
" Include matching uppercase words with lowercase search term
set ignorecase
" Include only uppercase words with uppercase search term
set smartcase

" Store info from no more than 100 files at a time, 9999 lines of text, 100kb of data. Useful for copying large amounts of data between files.
set viminfo='100,<9999,s100


" Use persistent history.
set history=10000
if has("nvim")
    set undodir=$HOME/.cache/nvim/undo
    set backupdir=$HOME/.cache/nvim/backup
else
    set undodir=$HOME/.cache/vim/undo
    set backupdir=$HOME/.cache/vim/backup
endif
set undofile
set noswapfile
set backup
if !isdirectory(&undodir)
  call mkdir(&undodir, 'p')
endif
if !isdirectory(&backupdir)
  call mkdir(&backupdir, 'p')
endif

"don't save for temp files and don't leak passwords through pass
au BufWritePre /tmp/* setlocal noundofile
au BufWritePre /dev/shm/* setlocal noundofile
set backupskip+=/dev/shm/*

" always be where the file is
" set autochdir


" make splits open on the right side
set splitright

" select with mouse in vim
set mouse=a
if !has("nvim")
    if has("mouse_sgr")
        set ttymouse=sgr
    else
        set ttymouse=xterm2
    end
endif


" Cursor shape
if &term =~? 'contour' || &term =~? 'tmux-256color' || &term =~? 'xterm-256color'
    " 1 or 0 -> blinking block
    " 2 -> solid block
    " 3 -> blinking underscore
    " 4 -> solid underscore
    " Recent versions of xterm (282 or above) also support
    " 5 -> blinking vertical bar
    " 6 -> solid vertical bar
    " :h t_SI
    " Enter Insert Mode
    let &t_SI .= "\<Esc>[6 q"
    " Enter Normal Mode
    let &t_EI .= "\<Esc>[2 q"
    " 'Usual' cursor
    let &t_VS .= "\<Esc>[2 q"

    " au VimEnter * silent !echo -ne "\<Esc>[2 q"
endif

" this is pretty irritating really :)
" au WinLeave * set nocursorline nocursorcolumn
" au WinEnter * set cursorline cursorcolumn
" set cursorline cursorcolumn

" this is needed so kitty's protocol doesn't turn the menu key into a large undo
set <F20>=57363u
