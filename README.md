# .files

My dotfiles and explanations/documentation for myself.

## dotfile management

I use [yadm](https://github.com/TheLocehiliosan/yadm) because it is essentially a bare git repo, with some nice additional features.


## getting started

Requirements (just approximate):
- git >= 2.34.1
- zsh >= 5.1
- vim >= 8.2 (much newer for everything)

### minimal quickstart

```
bash <(curl -sS https://raw.githubusercontent.com/ferdinandyb/dotfiles/master/.config/yadm/minimalbootstrap)
```

### manual
Install yadm:
```
curl -fLo ~/.local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x ~/.local/bin/yadm
```

Clone the repo:
```
yadm clone https://github.com/ferdinandyb/dotfiles.git
```

Or if you have a key on the machine:
```
yadm clone git@github.com:ferdinandyb/dotfiles.git
```

### sparse-checkout and alternates

Way to set the classes (currently all alternates are based on this):

```
yadm config --add local.class imap
```

Current existing classes:
 - imap: set aerc to use imap instead of maildir
 - minimal: sparse-checkout
 - org: sparse-checkout

To use sparse-checkout after cloning set the appropriate classes then run:

```
yadm sparse-checkout reapply
```

See [sparse-checkout template](https://github.com/ferdinandyb/dotfiles/blob/master/.local/share/yadm/repo.git/info/sparse-checkout%23%23template).

## usage

The below function sets up vim so that fugitive works properly with yadm and my
editing history is preserved.

```sh
function confed(){
  env GIT_DIR=$HOME/.local/share/yadm/repo.git GIT_WORK_TREE=$HOME \
  vim -c "cd ~" \
      -c "let g:rooter_change_directory_for_non_project_files = 'home'" \
      -c "silent AutoSaveToggle" \
      -S ~/.local/share/yadm/Session.vim
}
```

And the below vim setup allows for fzf search among my dotfiles.

```vim
command! -bang -nargs=? -complete=dir FYadm
            \ call fzf#run(fzf#wrap('yadm',
            \ fzf#vim#with_preview(
            \ { 'dir': <q-args>,
            \ 'source': 'yadm list -a' }), <bang>0))

nmap <leader>y :FYadm!<CR>
```


## Desktop

I currently run [CachyOS](https://cachyos.org/) with i3, which is mostly a port
of my old [Regolith 3](https://regolith-desktop.com/) config (a complete port
of Regolith 3 to CachyOS later down the line is not out of question).


## Terminal stuff

- [contour](https://contour-terminal.org/) (but mostly `wezterm` on WSL)
- `zsh`: took a long time to switch from bash, but the fast `powerlevel10k` prompt (vs `starship.rs` which lagged) was the final nail in the coffin, although I still have bash set up with `ble.sh`, which is pretty great (probably a bit better than what zsh provides through the vim-mode and syntax highlight plugins)
- `tmux`
- `fzf`, `fd-find`, `ripgrep`, and [ugrep](https://github.com/Genivia/ugrep) wherever they make sense
- `zoxide` for navigation or sometimes `yazi`


### airline themes for tmux

If you change the airline theme in vim, to have matching themes in tmux, open
vim inside a tmux session and execute:
```
:Tmuxline airline full
:TmuxlineSnapshot ~/.tmux/tmuxline_theme.sh
```

## Email

I wrote a [tutorial](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/) which basically covers my setup.

Deduplication of emails:

```
for i in {2007..2022}; do mdedup $i -i maildir -s discard-all-but-one -a delete-discarded; done
```

## WSL

See [here](.config/wsl/README.md).
