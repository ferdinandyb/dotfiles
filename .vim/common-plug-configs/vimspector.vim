Plug 'puremourning/vimspector'
Plug 'sagi-z/vimspectorpy', { 'do': { -> vimspectorpy#update() } }

let g:vimspector_install_gadgets = [ 'debugpy', 'CodeLLDB', 'delve' ]
let g:vimspectorpy#tmux#split = "h"
let g:vimspectorpy#tmux#size = 100
" for normal mode - the word under the cursor
nmap <leader>vi <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <leader>vi <Plug>VimspectorBalloonEval

nmap <leader>vc <Plug>VimspectorContinue
nmap <leader>vs <Plug>VimspectorStop
nmap <leader>vr <Plug>VimspectorRestart
nmap <leader>vp <Plug>VimspectorPause
nmap <leader>vb <Plug>VimspectorToggleBreakpoint
nmap <leader>vB <Plug>VimspectorToggleConditionalBreakpoint
nmap <leader>vf <Plug>VimspectorAddFunctionBreakpoint
nmap <leader>vo <Plug>VimspectorRunToCursor
nmap <leader>vj <Plug>VimspectorStepOver
nmap <leader>vl <Plug>VimspectorStepInto
nmap <leader>vh <Plug>VimspectorStepOut
nmap <leader>vw :VimspectorWatch
nmap <leader>vq :VimspectorReset<Enter>
nmap <leader>vL <Plug>VimspectorBreakpoints
nmap <leader>vd <Plug>VimspectorDisassemble
nmap <F11> <Plug>VimspectorUpFrame
nmap <F12> <Plug>VimspectorDownFrame
