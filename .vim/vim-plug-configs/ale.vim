Plug 'dense-analysis/ale'
let g:ale_disable_lsp = 1
let g:ale_cursor_detail = 0
let g:ale_detail_to_floating_preview=1
let g:ale_echo_msg_format = '%linter% - %code: %%s'
let g:ale_cache_executable_check_failures = 1

let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']
let g:ale_hover_to_preview = 1
let g:ale_hover_to_floating_preview  = 1


" TODO: set nicer signs for the column!
" g:ale_sign_warning                                         *g:ale_sign_warning*
" g:ale_sign_error                                             *g:ale_sign_error*


" check the defaults before chaning this! TODO move to filetype?
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['ruff']
\}

let g:ale_fixers = {
\   '*': ['remove_trailing_lines','trim_whitespace'],
\   'python': ['black', 'pyflyby', 'isort'],
\   'go': ['gofumpt'],
\   'vue': ['prettier']
\}

let g:ale_fix_on_save = 1
nmap <silent> ]h <Plug>(ale_next_wrap_error)
nmap <silent> [h <Plug>(ale_previous_wrap_error)
nmap <silent> [w <Plug>(ale_previous_wrap)
nmap <silent> ]w <Plug>(ale_next_wrap)
