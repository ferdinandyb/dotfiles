alias vims="/usr/bin/vim --servername VIMSERVER"
alias nv="/usr/bin/nvim"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias t="tmux"
alias tls="tmux ls"
alias tns="tmux new -s"
alias jn="jupyter notebook"
alias ts="$HOME/.tmux/scripts/fzf-change-session.tmux tmux_fzf_change_session"
alias tn="$HOME/.tmux/scripts/fzf-change-session.tmux tmux_fzf_new_session"
alias r='printf "\033];Ranger\007"; ranger; printf "\033];Terminal\007"'
alias lsr="ls -tr"

# cetli.vim
#
function ccn(){
    vim +'call feedkeys(":CetliNew ")'
}

function cfn(){
    vim +'call feedkeys(":FecniNew ")'
}

function cin(){
    vim +'call feedkeys(":InboxNew ")'
}

function crn(){
    vim +'call feedkeys(":ResourceNew ")'
}

function ccs(){
    vim +'call feedkeys(":CetliSearch\<CR>")'
}

function cfs(){
    vim +'call feedkeys(":FecniSearch\<CR>")'
}

function cis(){
    vim +'call feedkeys(":InboxSearch\<CR>")'
}

function crs(){
    vim +'call feedkeys(":ResourceSearch\<CR>")'
}

function cas(){
    vim +'call feedkeys(":AgendaSearch\<CR>")'
}

function cps(){
    vim +'call feedkeys(":ProjectSearch\<CR>")'
}

function cs(){
    cd ~/org
    vim +'call feedkeys(":FGitFiles\<CR>")'
}

function ccl(){
    cd ~/org/cetlidoboz
    vim `fd "\d{8}\.md" | tail -n 1`
}

function cfl(){
    cd ~/org/fecnidoboz
    vim `fd "\d{8}\.md" | tail -n 1`
}

function cil(){
    cd ~/org/fecnidoboz
    vim `fd "\d{8}\.md" | tail -n 1`
}

function crl(){
    cd ~/org/resources
    vim `fd "\d{8}\.md" | tail -n 1`
}

function cpl(){
    cd ~/org/projects
    vim `ls -tr | tail -n 1`
}

function cal(){
    cd ~/org/agendas
    vim `ls -tr | tail -n 1`
}
