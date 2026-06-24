" Treesitter (neovim only): syntax highlighting, folds, sticky context, motions,
" and text objects (SELECT keymaps still TBD — see treesitter-bindings.md).
" (Swapping stays with vim-swap on both editors — treesitter swap is redundant.)
"
" Classic vim keeps polyglot / SimpylFold / FastFold / vim-pythonsense instead
" (see vim-plug-configs/). Parsers are per-machine build artifacts compiled by
" the tree-sitter CLI (`brew install tree-sitter-cli`); they are NOT tracked by
" yadm. Without the CLI, `vim.treesitter.start()` fails and we fall back to the
" built-in :syntax highlighting (see the pcall in the FileType autocmd).
"
" Configured on `User PlugLoaded` (fired by vimrc after plug#end()), same hook
" gitsigns and lualine use.

function! s:setup_treesitter() abort
lua << EOF
local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then return end

ts.setup({})

-- Parsers to build. Highlighting falls back to :syntax for anything not here.
local parsers = {
  'lua', 'vim', 'vimdoc', 'query', 'bash', 'python', 'markdown',
  'markdown_inline', 'json', 'yaml', 'toml', 'gitcommit', 'diff',
  'javascript', 'typescript', 'html', 'css', 'c', 'rust', 'go',
}
if vim.fn.executable('tree-sitter') == 1 then
  ts.install(parsers)
end

-- Folds open by default; treesitter only computes them where a parser attaches.
vim.o.foldlevelstart = 99

-- Text objects + moves. setup() options now; SELECT keymaps (af/if, …) still TBD
-- (see ~/Codes/localreview/treesitter-bindings.md). Require the move module once.
local move_ok, move = pcall(require, 'nvim-treesitter-textobjects.move')
if move_ok then
  require('nvim-treesitter-textobjects').setup({
    select = { lookahead = true },
    move = { set_jumps = true },
  })
end

-- gitcommit stays on built-in :syntax: it flags subject overflow (>50/72 cols)
-- and a non-blank second line (gitcommitOverflow/gitcommitBlank); the treesitter
-- grammar has no overflow node, so TS highlighting loses both warnings.
local keep_builtin_syntax = { gitcommit = true }

-- Enable treesitter highlighting + folds per buffer, but only where a parser
-- actually attaches (pcall keeps non-parsed filetypes on built-in :syntax), and
-- map the move motions buffer-local: class ]c/[c (start) + ]C/[C (end), function
-- ]m/[m (start) + ]M/[M (end). (]c is free since change/hunk nav lives on ]h.)
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if keep_builtin_syntax[args.match] then return end
    if not pcall(vim.treesitter.start) then return end
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    if not move_ok then return end
    local function m(key, fn, cap)
      vim.keymap.set({ 'n', 'x', 'o' }, key,
        function() move[fn](cap, 'textobjects') end, { buffer = args.buf })
    end
    m(']c', 'goto_next_start', '@class.outer')
    m('[c', 'goto_previous_start', '@class.outer')
    m(']C', 'goto_next_end', '@class.outer')
    m('[C', 'goto_previous_end', '@class.outer')
    m(']m', 'goto_next_start', '@function.outer')
    m('[m', 'goto_previous_start', '@function.outer')
    m(']M', 'goto_next_end', '@function.outer')
    m('[M', 'goto_previous_end', '@function.outer')
  end,
})

-- Sticky header showing the function/class the cursor is inside.
pcall(function() require('treesitter-context').setup({}) end)
EOF
endfunction

autocmd User PlugLoaded ++nested call s:setup_treesitter()
