Plug 'jpalardy/vim-slime'
let g:slime_bracketed_paste = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
let g:slime_target = "tmux"

let g:slime_no_mappings = 1
xmap <leader>s <Plug>SlimeRegionSend
nmap <leader>s <Plug>SlimeParagraphSend
" nmap <c-c>v     <Plug>SlimeConfig


nmap <leader>S <Plug>SlimeSendCell
