alias vims="/usr/bin/vim --servername VIMSERVER"
alias nv="/usr/bin/nvim"
alias v="vim"
alias vl="vim --cmd 'let g:lightweight=1'"

alias icat="kitty +kitten icat"
alias kd="kitty +kitten diff"
alias week="date +%V"

alias citemarkdown="bibtex-ls ~/org/zotero.bib | fzf | bibtex-markdown ~/org/zotero.bib | xclip -selection clipboard"


alias t="tmux"
alias tls="tmux ls"
alias tns="tmux new -s"
alias tna="tmux new-session -t"
alias ta="tmux attach -t"
alias jn="jupyter notebook"
alias ts="$HOME/.tmux/scripts/fzf-change-session.tmux tmux_fzf_change_session"
alias tn="$HOME/.tmux/scripts/fzf-change-session.tmux tmux_fzf_new_session"
alias r='. ranger'
alias r.="kitty ranger"
alias bm="bashmount"
alias cdl='cd  "$(\ls -1dt ./*/ | head -n 1)"' # cd into last modified directory
alias s="kitty +kitten ssh"
alias xo="xargs -i xdg-open {}"
alias clip="xclip -selection c"
alias scu="systemctl --user"
alias jcu="journalctl --user"

alias g="git"
alias lazyadm="lazygit -w ~ -g ~/.local/share/yadm/repo.git"

alias ad="aerc > ~/.aerc.log"

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

## cetli.vim
##
#function ccn(){
#    vim +'call feedkeys(":CetliNew ")'
#}

#function cfn(){
#    vim +'call feedkeys(":FecniNew ")'
#}

#function cin(){
#    vim +'call feedkeys(":InboxNew ")'
#}

#function crn(){
#    vim +'call feedkeys(":ResourceNew ")'
#}

#function ccs(){
#    vim +'call feedkeys(":CetliSearch\<CR>")'
#}

#function cfs(){
#    vim +'call feedkeys(":FecniSearch\<CR>")'
#}

#function cis(){
#    vim +'call feedkeys(":InboxSearch\<CR>")'
#}

#function crs(){
#    vim +'call feedkeys(":ResourceSearch\<CR>")'
#}

#function cas(){
#    vim +'call feedkeys(":AgendaSearch\<CR>")'
#}

#function cps(){
#    vim +'call feedkeys(":ProjectSearch\<CR>")'
#}

#function cs(){
#    cd ~/org
#    vim +'call feedkeys(":FGitFiles\<CR>")'
#}

#function ccl(){
#    cd ~/org/cetlidoboz
#    vim `fd "\d{8}\.md" | tail -n 1`
#}

#function cfl(){
#    cd ~/org/fecnidoboz
#    vim `fd "\d{8}\.md" | tail -n 1`
#}

#function cil(){
#    cd ~/org/fecnidoboz
#    vim `fd "\d{8}\.md" | tail -n 1`
#}

#function crl(){
#    cd ~/org/resources
#    vim `fd "\d{8}\.md" | tail -n 1`
#}

#function cpl(){
#    cd ~/org/projects
#    vim `ls -tr | tail -n 1`
#}

#function cal(){
#    cd ~/org/agendas
#    vim `ls -tr | tail -n 1`
#}
