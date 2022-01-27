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

function cmn(){
    vim +'call feedkeys(":MeetingNew ")'
}

function ccl(){
    cd ~/org/cetlidoboz
    git pull
    vim `fd "\d{8}\.md" | tail -n 1`
}

function cfl(){
    cd ~/org/fecnidoboz
    git pull
    vim `fd "\d{8}\.md" | tail -n 1`
}

function cml(){
    cd ~/org/meetings
    git pull
    vim `fd "\d{8}\.md" | tail -n 1`
}


function sync_repo(){
    curdir=`pwd`
    for folder in $@
    do
        cd $folder
        git pull
        git push
    done
    cd $curdir
}

alias cs="sync_repo ~/org"
