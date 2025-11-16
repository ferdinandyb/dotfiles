alias vims="/usr/bin/vim --servername VIMSERVER"
alias nvs="nvim --listen ./.nvim.sock"
alias v="vim"
alias vl="vim --cmd 'let g:lightweight=1'"

alias week="date +%V"
alias diary="vim +VimwikiMakeDiaryNote"

alias bw-ssh='SSH_AUTH_SOCK=$HOME/.bitwarden-ssh-agent.sock ssh'
alias alias-gpg-ssh='export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)" ssh'
alias set-bw-ssh='export SSH_AUTH_SOCK=$HOME/.bitwarden-ssh-agent.sock'
alias set-gpg-ssh='export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"'

alias citemarkdown="bibtex-ls ~/org/zotero.bib | fzf | bibtex-markdown ~/org/zotero.bib | xclip -selection clipboard"

alias t="task"
alias ta="task add"
alias tt="taskwarrior-tui"
alias tmux-new-attach="tmux new-session -t"

alias bm="bashmount"
alias cdl='cd  "$(\ls -1dt ./*/ | head -n 1)"' # cd into last modified directory
alias cr='cd $(git rev-parse --show-toplevel)'
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

# Shortcuts for switching Databricks workspaces
alias dbx_aws_sdp='export DATABRICKS_CONFIG_PROFILE=aws-sdp; databricks auth login --profile aws-sdp'
alias dbx_gcp_prod='export DATABRICKS_CONFIG_PROFILE=gcp-prod; databricks auth login --profile gcp-prod'
alias dbx_gcp_prod_dev='export DATABRICKS_CONFIG_PROFILE=gcp-prod-dev; databricks auth login --profile gcp-prod-dev'

# Use AWS by default
export DATABRICKS_CONFIG_PROFILE=aws-sdp
