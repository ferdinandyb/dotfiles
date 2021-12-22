# Bence Ferdinandy's dotfiles

I choose [yadm](https://github.com/TheLocehiliosan/yadm) because it is basically
a bare git repo if I don't need anything fancy, meaning the structure and files
are the same as on the machine, but it has the fancy things I occasionally need.

`.local/bin/yamdlistall` will list all files managed by `yamd` until hopefully
`yamd` will have built-in [solution
](https://github.com/TheLocehiliosan/yadm/issues/392).

# airline themes for tmux and bash

If you change the airline theme in vim, to have matching themes in tmux, open
vim inside a tmux session and execute:
```
:Tmuxline airline full
:TmuxlineSnapshot ~/.tmux/tmuxline_theme.sh
```

For the bash prompt execute:
```
:PromptlineSnapshot ~/.config/bash/promptline_theme.sh airline clear
```

