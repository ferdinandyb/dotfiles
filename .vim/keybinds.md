# Vim keybindings

I use space as <leader>.

## Everyday keys

| key                   | does                         |
| --------------------- | ---------------------------- |
| `<leader>g`             | open a git-tracked file      |
| `<leader>b`             | switch buffer                |
| `<leader>,`             | jump to the previous buffer  |
| `<leader>ö` / `<leader>ü` | split / vertical split       |
| `<leader>m`             | clear search highlight       |
| `<leader>q`             | reflow the current paragraph |
| `<leader>R`             | reload my config             |

Quick search aliases (no topic letter, because I use them all the time):
`<leader>*` ripgrep the word under the cursor · `<leader>é` command history ·
`<leader>/` search history.

## Find things — `<leader>f`  *(fzf)*

| key | does                      | key | does              |
| --- | ------------------------- | --- | ----------------- |
| `ff`  | files                     | `fw`  | windows           |
| `fa`  | all files (incl. ignored) | `fc`  | document sections |
| `ft`  | tags                      | `fb`  | git branches      |
| `fr`  | ripgrep                   | `fh`  | command history   |
| `fm`  | marks                     | `fy`  | dotfiles          |
| `fl`  | lines in buffer           |     |                   |

## Code — `<leader>l` and the `g` jumps  *(coc.nvim)*

Jump around (no leader): `gd` definition · `gy` type definition ·
`gz` implementation · `gr` references · `gR` references used · `K` hover docs.

Act on code:

| key | does                                               |
| --- | -------------------------------------------------- |
| `lr`  | rename                                             |
| `lR`  | refactor                                           |
| `lc`  | code action (under cursor)                         |
| `la`  | code action (over a motion/selection, e.g. `laap`) |
| `lC`  | code action (whole line)                           |
| `lf`  | format (motion/selection)                          |
| `lx`  | quick-fix the current line                         |
| `lo`  | symbol outline                                     |
| `ll`  | all coc lists                                      |

## Debug — `<leader>v`  *(vimspector)*

| key | does                   | key | does          |
| --- | ---------------------- | --- | ------------- |
| `vc`  | continue               | `vj`  | step over     |
| `vs`  | stop                   | `vl`  | step into     |
| `vr`  | restart                | `vh`  | step out      |
| `vp`  | pause                  | `vo`  | run to cursor |
| `vb`  | breakpoint             | `vw`  | add watch     |
| `vB`  | conditional breakpoint | `vq`  | reset         |
| `vf`  | function breakpoint    | `vi`  | inspect value |
| `vL`  | breakpoint list        | `vd`  | disassemble   |

`F11` / `F12` move up / down the stack frame.

## Git

Hunks live under `<leader>h`  *(gitsigns)*:

| key | does         | key | does                   |
| --- | ------------ | --- | ---------------------- |
| `hs`  | stage hunk   | `hp`  | preview hunk           |
| `hr`  | reset hunk   | `hb`  | blame this line        |
| `hS`  | stage buffer | `hd`  | diff this file         |
| `hR`  | reset buffer | `hq`  | send hunks to quickfix |

`hs` / `hr` also work over a visual selection.

The rest is fugitive: `gs` status · `gS` status in a vertical split ·
`<leader>Gd` vertical diff · `<leader>Gb` copy the file's web URL (works on a
visual range too).

## AI — `<leader>a`  *(opencode.nvim)*

`aa` ask about this · `as` pick a session · `ap` prompt with this · `at` toggle
the window.

## REPL — `<leader>s`  *(vim-slime)*

`sm` send a motion · `ss` send the line · `sp` send the paragraph · `S` send the
cell · in visual mode, `<leader>s` sends the selection.

## Toggles — `<leader>t` and the function keys

`tb` line blame · `tw` word diff · `tg` distraction-free (Goyo).

`F2` LSP · `F3` linter · `F4` autosave · `F5` spell check · `F6` undo tree ·
`F8` tag bar.

## Sessions — `<leader>o`  *(vim-obsession)*

`os` start/stop recording the session · `ol` load `Session.vim`.

## Writing & notes

Wiki *(vimwiki)* uses the standard `<leader>w` maps: `ww` index ·
`wt` index in a new tab · `ws` pick a wiki · `<leader>w<leader>w` today's diary.

Citations *(bibtexcite)*: `<leader>nc` inserts a citation (LaTeX and Markdown
buffers do the right thing automatically).

## Filetype-specific

- **Python** *(jupyter_ascending)* — `<leader>j`: `jx` run cell · `jX` run all ·
  `jr` restart the kernel.
- **Email** — `<leader>e` / `<leader>E`: insert an address (aerc / general).
