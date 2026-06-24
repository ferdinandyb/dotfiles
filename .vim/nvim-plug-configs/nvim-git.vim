" Git sign-column / hunk plugin for neovim only.
" Classic vim uses vim-gitgutter instead (vim-plug-configs/vim-git.vim).
" Shared git plugins (fugitive, flog, ...) live in common-plug-configs/common-git.vim.

Plug 'lewis6991/gitsigns.nvim'

" gitsigns must be configured AFTER plug#end() has added it to the runtimepath.
" The vimrc fires `User PlugLoaded` right after plug#end(), same hook the
" colorscheme and lualine use.
function! s:setup_gitsigns() abort
lua << EOF
local ok, gitsigns = pcall(require, 'gitsigns')
if not ok then return end

gitsigns.setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- ]h/[h = next/prev change: hunk normally, native change-jump in diff mode.
    -- (]c/[c are freed for treesitter @class — see nvim-treesitter.vim.)
    map('n', ']h', function()
      if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
    end)
    map('n', '[h', function()
      if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
    end)

    -- Stage / reset (hu kept as an alias for reset_hunk: old gitgutter muscle memory)
    map('n', '<leader>hs', gs.stage_hunk)
    map('n', '<leader>hr', gs.reset_hunk)
    map('n', '<leader>hu', gs.reset_hunk)
    map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
    map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
    map('v', '<leader>hu', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hR', gs.reset_buffer)

    -- Preview / blame / diff
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hi', gs.preview_hunk_inline)
    map('n', '<leader>hb', function() gs.blame_line({ full = true }) end)
    map('n', '<leader>hB', gs.blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)

    -- Quickfix
    map('n', '<leader>hq', gs.setqflist)
    map('n', '<leader>hQ', function() gs.setqflist('all') end)

    -- Toggles
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>tw', gs.toggle_word_diff)

    -- Text object (ih/ah, matching the vim/gitgutter side; frees ic/ac for treesitter @class)
    map({ 'o', 'x' }, 'ih', gs.select_hunk)
    map({ 'o', 'x' }, 'ah', gs.select_hunk)
  end,
})
EOF
endfunction

autocmd User PlugLoaded ++nested call s:setup_gitsigns()
