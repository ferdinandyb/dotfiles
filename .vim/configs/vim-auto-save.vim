" this provides the autosave toggle
Plug '907th/vim-auto-save'
" autosave normally saves on exiting insertmode, which is slow
let g:auto_save_events = ["WinLeave","BufLeave","CursorHold"]

augroup autosave_insertmode_ft
    au!
    au FileType markdown let b:auto_save_events = ["WinLeave","BufLeave","CursorHold","CursorHoldI"]
augroup END

