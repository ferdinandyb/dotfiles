# source ~/.config/environment.d when we're not inheriting from systemd
if [ "$SYSTEMDUSERENVLOADED" != 1 ]; then
  if ! type "$systemctl" > /dev/null; then

    # this seems like an ugly hack for MacOS
    for file in $HOME/.config/environment.d/*.conf; do
      while IFS= read -r line; do
	  # Skip empty lines or comments if necessary
	  [[ -z "$line" || "$line" =~ ^# ]] && continue
	  eval "export $line"
      done < $file
    done
  else
    export $(systemctl --user show-environment | xargs)
  fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


for file in $HOME/.config/shell/zsh/*.zsh; do
  source $file
done

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

if [ -f $HOME/.config/shell/aliases.sh ]; then
  source $HOME/.config/shell/aliases.sh
fi

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

if [ -d /opt/homebrew/bin ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi



if ! type "$zoxide" > /dev/null; then
  eval "$(zoxide init zsh)"
fi


function confed(){
  env GIT_DIR=$HOME/.local/share/yadm/repo.git GIT_WORK_TREE=$HOME \
  vim -c "cd ~" \
      -c "let g:rooter_change_directory_for_non_project_files = 'home'" \
      -c "silent AutoSaveToggle" \
      -S ~/.local/share/yadm/Session.vim
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}



export ZVM_VI_SURROUND_BINDKEY=s-prefix
zvm_after_init() {
  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null
  if [ -f  '/usr/local/bin/aws_completer' ]; then
    complete -C '/usr/local/bin/aws_completer' aws
  fi

  # Key bindings
  # ------------
  source <(fzf --zsh)
  bindkey "\C-z" vi-forward-word
  bindkey "\C-]" autosuggest-accept
  bindkey "\C-ú" autosuggest-accept
  # bindkey "^M" autosuggest-accept
}
# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh




_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

if [ -d $HOME/.cargo/env ]; then
  . "$HOME/.cargo/env"
fi


if [[ -f /proc/version && $(grep -i Microsoft /proc/version) ]]; then
    export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
    ss -a | grep -q $SSH_AUTH_SOCK
    if [ $? -ne 0 ]; then
    rm -f $SSH_AUTH_SOCK
    setsid nohup socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:/mnt/c/bferdinandy/bin/wsl2-ssh-pageant.exe &>/dev/null &
    fi
    # to use gpg on wsl simply symlink the windows executable
    export VAXIS_FORCE_LEGACY_SGR=1
    export VAXIS_FORCE_UNICODE=1
elif [ $(hostname) = mashenka -o $(hostname) = MBP-Bence-Ferdinandy ]; then
  unset SSH_AGENT_PID
  if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
fi

if [ -d /usr/share/contour/shell-integration ]; then
  source /usr/share/contour/shell-integration/shell-integration.zsh
fi

if [ -d $HOME/.local/share/zsh/site-functions/_hut ]; then
source  /home/fbence/.local/share/zsh/site-functions/_hut
fi

if [ -d $HOME/.config/glab-cli/completion.zsh ]; then
  source $HOME/.config/glab-cli/completion.zsh
fi

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env
