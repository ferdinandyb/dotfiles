# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source $HOME/.config/shell/zsh/antigen.zsh
# Plugins
antigen bundle Aloxaf/fzf-tab
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle jeffreytse/zsh-vi-mode

antigen use oh-my-zsh
antigen bundle dirhistory
antigen bundle taskwarrior

antigen theme romkatv/powerlevel10k

antigen apply


HISTSIZE=500000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=500000
setopt appendhistory
setopt HIST_IGNORE_ALL_DUPS
setopt nonomatch
# # options that should be mostly pretty agreeable: from https://github.com/willghatch/zsh-saneopt/blob/master/saneopt.plugin.zsh

# no c-s/c-q output freezing
setopt noflowcontrol
# # allow expansion in prompts
# setopt prompt_subst
# # this is default, but set for share_history
# setopt append_history
# # save each command's beginning timestamp and the duration to the history file
# # setopt extended_history
# # display PID when suspending processes as well
# setopt longlistjobs
# # try to avoid the 'zsh: no matches found...'
# setopt nonomatch
# # report the status of backgrounds jobs immediately
# setopt notify
# # whenever a command completion is attempted, make sure the entire command path
# # is hashed first.
# setopt hash_list_all
# # not just at the end
# setopt completeinword
# # use zsh style word splitting
# setopt noshwordsplit
# allow use of comments in interactive code
setopt interactivecomments

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export PYTHONPATH="$PYTHONPATH:$HOME/Codes"
export EDITOR=vim
if [ -f $HOME/.config/shell/aliases.sh ]; then
  source $HOME/.config/shell/aliases.sh
fi
# go
export PATH=$HOME/go/bin:$PATH

# fnm

if [ -d $HOME/.fnm ]; then
    export PATH=$HOME/.fnm:$PATH
    eval "`fnm env`"

elif [ -d $HOME/.local/share/fnm ]; then
  export PATH=$HOME/.local/share/fnm:$PATH
  eval "`fnm env`"
fi


if [ -d $HOME/.pyenv ]; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
fi

export PATH=$PATH:/usr/local/go/bin


eval "$(zoxide init zsh)"

function confed(){
  env GIT_DIR=$HOME/.local/share/yadm/repo.git GIT_WORK_TREE=$HOME \
  vim -c "let g:rooter_change_directory_for_non_project_files = 'home'" \
      -c "silent AutoSaveToggle" \
      `yadmlistall`
}




zvm_after_init() {
  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

  # Key bindings
  # ------------
  source "$HOME/.fzf/shell/key-bindings.zsh"
  bindkey "\C-z" autosuggest-accept
  # bindkey "^M" autosuggest-accept
}
# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER='óó'
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --bind "alt-a:select-all,alt-d:deselect-all"'



_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

. "$HOME/.cargo/env"

if [[ $(grep -i Microsoft /proc/version) ]]; then
    export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
    ss -a | grep -q $SSH_AUTH_SOCK
    if [ $? -ne 0 ]; then
    rm -f $SSH_AUTH_SOCK
    setsid nohup socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:/mnt/c/bferdinandy/bin/wsl2-ssh-pageant.exe &>/dev/null &
    fi
    # GPG Socket
    # Removing Linux GPG Agent socket and replacing it by link to wsl2-ssh-pageant GPG socket
    export GPG_AGENT_SOCK=$HOME/.gnupg/S.gpg-agent
    ss -a | grep -q $GPG_AGENT_SOCK
    if [ $? -ne 0 ]; then
    rm -rf $GPG_AGENT_SOCK
    setsid nohup socat UNIX-LISTEN:$GPG_AGENT_SOCK,fork EXEC:"/mnt/c/bferdinandy/bin/wsl2-ssh-pageant.exe --gpg S.gpg-agent" &>/dev/null &
    fi
elif [ $(hostname) = mashenka ]; then
  unset SSH_AGENT_PID
  if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
fi

if [ -d $HOME/.local/softwarefromsource/contour/src/contour/shell-integration ]; then
source $HOME/.local/softwarefromsource/contour/src/contour/shell-integration/shell-integration.zsh
fi

if [ -d $HOME/.config/glab-cli/completion.zsh ]; then
  source $HOME/.config/glab-cli/completion.zsh
fi

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env
