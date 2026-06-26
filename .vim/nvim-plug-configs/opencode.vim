Plug 'NickvanDyke/opencode.nvim'

" AI namespace: opencode under <leader>a* (leader = space)
nnoremap <leader>aa <cmd>lua require("opencode").ask("@this: ", { submit = true })<cr>
xnoremap <leader>aa <cmd>lua require("opencode").ask("@this: ", { submit = true })<cr>
nnoremap <leader>as <cmd>lua require("opencode").select()<cr>
xnoremap <leader>as <cmd>lua require("opencode").select()<cr>
nnoremap <leader>ap <cmd>lua require("opencode").prompt("@this")<cr>
xnoremap <leader>ap <cmd>lua require("opencode").prompt("@this")<cr>
nnoremap <leader>at <cmd>lua require("opencode").toggle()<cr>
tnoremap <leader>at <cmd>lua require("opencode").toggle()<cr>
