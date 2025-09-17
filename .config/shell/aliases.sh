alias vims="/usr/bin/vim --servername VIMSERVER"
alias v="vim"
alias vl="vim --cmd 'let g:lightweight=1'"

alias week="date +%V"
alias diary="vim +VimwikiMakeDiaryNote"

alias citemarkdown="bibtex-ls ~/org/zotero.bib | fzf | bibtex-markdown ~/org/zotero.bib | xclip -selection clipboard"

alias ts="$HOME/.tmux/scripts/fzf-change-session.tmux tmux_fzf_change_session"
alias tn="$HOME/.tmux/scripts/fzf-change-session.tmux tmux_fzf_new_session"
alias t="task"
alias ta="task add"
alias tt="taskwarrior-tui"
alias tmux-new-attach="tmux new-session -t"

alias bm="bashmount"
alias cdl='cd  "$(\ls -1dt ./*/ | head -n 1)"' # cd into last modified directory
alias cr='cd $(git rev-parse --show-toplevel)'
alias cd=z
alias xo="xargs -i xdg-open {}"
alias scu="systemctl --user"
alias jcu="journalctl --user"

alias jn="jupyter notebook"

alias g="git"
alias lazyadm="lazygit -w ~ -g ~/.local/share/yadm/repo.git"
alias yadiff="diff <(ls) <(yadm list)"

if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

alias ll='ls -ltrhA'
alias la='ls -A'
alias lh='ls -lh'
alias lt='ls -ltrh'
alias l='ls'
alias lf="ls -tr | tail -n1" #usage: command `lf`

alias t1="tree -L 1"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
