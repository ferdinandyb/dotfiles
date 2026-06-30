" Treesitter (neovim only): syntax highlighting, folds, sticky context, motions,
" and function/class text objects. Swapping stays with vim-swap on both editors.
"
" Classic vim keeps polyglot / SimpylFold / FastFold / vim-pythonsense instead
" (see vim-plug-configs/). Parsers are built on demand, and only when the
" tree-sitter CLI is available; without it `vim.treesitter.start()` fails and we
" fall back to built-in :syntax (see the pcall in the FileType autocmd).
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
  'javascript', 'typescript', 'html', 'css', 'c', 'rust', 'go', 'tmux',
}
if vim.fn.executable('tree-sitter') == 1 then
  ts.install(parsers)
end

-- Folds open by default; treesitter only computes them where a parser attaches.
vim.o.foldlevelstart = 99

-- Text objects + moves. select.lookahead / move.set_jumps set here; the SELECT
-- and MOVE keymaps are wired buffer-local below (see the autocmd).
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
-- actually attaches (pcall keeps non-parsed filetypes on built-in :syntax), then
-- map the motions and SELECT objects buffer-local:
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
    m(']g', 'goto_next_start', '@parameter.inner')
    m('[g', 'goto_previous_start', '@parameter.inner')
    m(']i', 'goto_next_start', '@conditional.outer')
    m('[i', 'goto_previous_start', '@conditional.outer')
    m(']u', 'goto_next_start', '@loop.outer')
    m('[u', 'goto_previous_start', '@loop.outer')
    m(']k', 'goto_next_start', '@comment.outer')
    m('[k', 'goto_previous_start', '@comment.outer')
    local sel = require('nvim-treesitter-textobjects.select')
    local function s(key, cap)
      vim.keymap.set({ 'x', 'o' }, key,
        function() sel.select_textobject(cap, 'textobjects') end, { buffer = args.buf })
    end
    s('if', '@function.inner')
    s('af', '@function.outer')
    s('ic', '@class.inner')
    s('ac', '@class.outer')
    s('ia', '@parameter.inner')
    s('aa', '@parameter.outer')
    s('ii', '@conditional.inner')
    s('ai', '@conditional.outer')
    s('iL', '@loop.inner')
    s('aL', '@loop.outer')
    s('iF', '@call.inner')
    s('aF', '@call.outer')
    s('iC', '@comment.inner')
    s('aC', '@comment.outer')
    s('i=', '@assignment.inner')
    s('a=', '@assignment.outer')
  end,
})

-- Sticky header showing the function/class the cursor is inside.
pcall(function() require('treesitter-context').setup({}) end)
EOF
endfunction

autocmd User PlugLoaded ++nested call s:setup_treesitter()
