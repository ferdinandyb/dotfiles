# Tmux Configuration

## Quick Reference

 | Function          | Key Binding                       | Source                      |
 |-------------------|-----------------------------------|-----------------------------|
 | Prefix            | `Ctrl-Space`                      | Config                      |
 | New Window        | `Prefix + c`                      | Config                      |
 | New Session       | `Prefix + Ctrl-n`                 | Config                      |
 | Horizontal Split  | `Prefix + ü`                      | Config                      |
 | Vertical Split    | `Prefix + ö`                      | Config                      |
 | Navigate Panes    | `Ctrl-h/j/k/l`                    | Plugin (vim-tmux-navigator) |
 | Last Pane         | `Ctrl-é`                          | Plugin (vim-tmux-navigator) |
 | Copy Mode         | `Prefix + Escape` or `Prefix + ő` | Config                      |
 | Visual Selection  | `v` (in copy mode)                | Config                      |
 | Paste             | `Prefix + p` or `Prefix + ú`      | Config                      |
 | Save Session      | `Prefix + S`                      | Plugin (tmux-resurrect)     |
 | Restore Session   | `Prefix + R`                      | Plugin (tmux-resurrect)     |
 | Fuzzy Pane Picker | `Prefix + Ctrl-p`                 | Script (fzf-panes.tmux)     |
 | Session Switcher  | `Prefix + Ctrl-s`                 | Plugin (tmux-fzf)           |
 | Pane Switcher     | `Prefix + Ctrl-w`                 | Plugin (tmux-fzf)           |
 | Last Pane Toggle  | `Prefix + ,`                      | Script (fzf-panes.tmux)     |
 | Install Plugins   | `Prefix + I`                      | Plugin (TPM)                |
 | Update Plugins    | `Prefix + U`                      | Plugin (TPM)                |
 | Remove Plugins    | `Prefix + Alt + U`                | Plugin (TPM)                |
 | Copy Command Line | `Prefix + y`                      | Plugin (tmux-yank)          |
 | Copy Working Dir  | `Prefix + Y`                      | Plugin (tmux-yank)          |
 | Copy Selection    | `y` (in copy mode)                | Plugin (tmux-yank)          |
 | Put Selection     | `Y` (in copy mode)                | Plugin (tmux-yank)          |
 | Regex Search      | `Prefix + /`                      | Plugin (tmux-copycat)       |
 | File Search       | `Prefix + Ctrl-f`                 | Plugin (tmux-copycat)       |
 | Git Status Search | `Prefix + Ctrl-g`                 | Plugin (tmux-copycat)       |
 | Hash Search       | `Prefix + Alt-h`                  | Plugin (tmux-copycat)       |
 | URL Search        | `Prefix + Ctrl-u`                 | Plugin (tmux-copycat)       |
 | Number Search     | `Prefix + Ctrl-d`                 | Plugin (tmux-copycat)       |
 | IP Search         | `Prefix + Alt-i`                  | Plugin (tmux-copycat)       |
 | Next Match        | `n` (in copycat mode)             | Plugin (tmux-copycat)       |
 | Previous Match    | `N` (in copycat mode)             | Plugin (tmux-copycat)       |
 | Open Selection    | `o` (in copy mode)                | Plugin (tmux-open)          |
 | Edit Selection    | `Ctrl-o` (in copy mode)           | Plugin (tmux-open)          |
 | Search Selection  | `Shift-s` (in copy mode)          | Plugin (tmux-open)          |
 | Butler Word Mode  | `Alt-i`                           | Plugin (tmux-butler)        |
 | Butler Path Mode  | `Alt-p`                           | Plugin (tmux-butler)        |
 | Butler Snippets   | `Alt-s`                           | Plugin (tmux-butler)        |

## Plugins

  | Plugin         | Description                        |
  |----------------|------------------------------------|
  | tpm            | Plugin manager                     |
  | tmux-resurrect | Save/restore sessions              |
  | tmux-continuum | Auto-save sessions                 |
  | tmux-yank      | System clipboard integration       |
  | tmux-copycat   | Enhanced search in copy mode       |
  | tmux-open      | Open highlighted text/URLs         |
  | tmux-butler    | Copy lines from visible panes      |
  | tmux-fzf       | FZF integration for sessions/panes |

## Scripts

  | Script                  | Description                      |
  |-------------------------|----------------------------------|
  | fzf-panes.tmux          | Advanced pane selection with MRU |
  | fzf-change-session.tmux | Session switching utilities      |
  | tmuxline_theme.sh       | Custom statusbar theme           |
