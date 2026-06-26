# --- zprof: profile what runs inside zsh. Uncomment this line AND the report
# block at the bottom of this file, then open a new shell to see the per-function
# table. zprof start must stay near the top so it captures everything. ---
# zmodload zsh/zprof && zprof
# --- end zprof start ---

# source ~/.config/environment.d when we're not inheriting from systemd
if [ "$SYSTEMDUSERENVLOADED" != 1 ]; then
	if ! type "$systemctl" >/dev/null; then

		# this seems like an ugly hack for MacOS
		for file in $HOME/.config/environment.d/*.conf; do
			while IFS= read -r line; do
				# Skip empty lines or comments if necessary
				[[ -z "$line" || "$line" =~ ^# ]] && continue
				eval "export $line"
			done <$file
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

if [ -f $HOME/.config/shell/aliases.sh ]; then
	source $HOME/.config/shell/aliases.sh
fi

# completions — use-omz owns compinit (deferred). We just add ~/.zfunc to fpath,
# enable bashcompinit (for `complete`, e.g. aws_completer), and set menu style.
fpath+=~/.zfunc
autoload -Uz bashcompinit && bashcompinit
zstyle ':completion:*' menu select

# antidote — portable zsh plugin manager. Install is per-OS and out of scope here
# (brew on mac, AUR `zsh-antidote` on arch, `git clone … ~/.antidote` on ubuntu).
# This finds antidote wherever it landed and skips cleanly if it's absent.
() {
	local f txt="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zsh_plugins.txt"
	for f in \
		"${ZDOTDIR:-$HOME}/.antidote/antidote.zsh" \
		"${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh" \
		/usr/local/opt/antidote/share/antidote/antidote.zsh \
		/home/linuxbrew/.linuxbrew/opt/antidote/share/antidote/antidote.zsh \
		/usr/share/zsh-antidote/antidote.zsh \
		/usr/share/zsh/plugins/antidote/antidote.zsh; do
		[[ -r $f ]] || continue
		source $f
		antidote load "$txt"
		return
	done
	[[ -o interactive ]] && print -ru2 -- "note: antidote not found; zsh plugins skipped (https://antidote.sh/install)"
}

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

if [ -d /opt/homebrew/bin ]; then
	export PATH="/opt/homebrew/bin:$PATH"
fi

if [ -d /home/linuxbrew/.linuxbrew ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PYTHONPATH="$PYTHONPATH:$HOME/Codes"

# do not tar annoying MacOS stuff
export COPYFILE_DISABLE=1


if ! type "$zoxide" >/dev/null; then
	eval "$(zoxide init zsh)"
fi

export ZVM_VI_SURROUND_BINDKEY=s-prefix
zvm_after_init() {
	# Auto-completion
	# ---------------
	[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2>/dev/null
	if [ -f '/usr/local/bin/aws_completer' ]; then
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


setup_ssh_agent() {
	unset SSH_AGENT_PID
	export GPG_TTY=$(tty)
	gpg-connect-agent updatestartuptty /bye >/dev/null
}

if [ $(hostname) = mashenka ]; then
	setup_ssh_agent
	if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
		export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/rbw/ssh-agent-socket"
	fi
elif [ $(hostname) = MBP-Bence-Ferdinandy ]; then
	setup_ssh_agent
	if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
		export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	fi
elif [[ -f /proc/version && $(grep -i Microsoft /proc/version) ]]; then
	export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
	ss -a | grep -q $SSH_AUTH_SOCK
	if [ $? -ne 0 ]; then
		rm -f $SSH_AUTH_SOCK
		setsid nohup socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:/mnt/c/bferdinandy/bin/wsl2-ssh-pageant.exe &>/dev/null &
	fi
	# to use gpg on wsl simply symlink the windows executable
	export VAXIS_FORCE_LEGACY_SGR=1
	export VAXIS_FORCE_UNICODE=1
fi

if [ -d /usr/share/contour/shell-integration ]; then
	source /usr/share/contour/shell-integration/shell-integration.zsh
fi

if [ -d $HOME/.local/share/zsh/site-functions/_hut ]; then
	source /home/fbence/.local/share/zsh/site-functions/_hut
fi

if [ -d $HOME/.config/glab-cli/completion.zsh ]; then
	source $HOME/.config/glab-cli/completion.zsh
fi

if type khal >/dev/null; then
	eval "$(_KHAL_COMPLETE=zsh_source khal)"
fi

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env
# BEGIN ANSIBLE MANAGED BLOCK - PROFILE.D
# Source files from profile.d directory
if [ -d "$HOME/.profile.d" ]; then
	# Handle empty glob patterns in both bash and zsh
	if [ -n "$ZSH_VERSION" ]; then
		setopt nullglob
	elif [ -n "$BASH_VERSION" ]; then
		shopt -s nullglob
	fi
	# Ensure files are loaded in alphabetical order
	for file in $(find "$HOME/.profile.d" -name "*.sh" -type f | sort); do
		if [ -r "$file" ]; then
			. "$file"
		fi
	done
	unset file
	# Reset glob behavior
	if [ -n "$ZSH_VERSION" ]; then
		unsetopt nullglob
	elif [ -n "$BASH_VERSION" ]; then
		shopt -u nullglob
	fi
fi
# END ANSIBLE MANAGED BLOCK - PROFILE.D

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/bence.ferdinandy/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/bence.ferdinandy/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/bence.ferdinandy/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/bence.ferdinandy/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
# Hook mode (used below): auto-activates project venvs + sets per-directory env,
# at a cost of ~10ms on every prompt.
# Shim alternative — ~0 per-prompt cost, but NO venv auto-activation / per-dir env:
#   command -v mise >/dev/null && eval "$(mise activate zsh --shims)"
if command -v mise >/dev/null && [[ -z ${MISE_SHELL:-} ]]; then
	eval "$(mise activate zsh)"
fi

# --- zprof report: dumps the profile once on first prompt, then unloads itself.
# Uncomment together with the `zprof` start block at the top of this file. ---
# autoload -Uz add-zsh-hook
# _zsh_zprof_report() {
# 	zprof
# 	zmodload -u zsh/zprof 2>/dev/null
# 	add-zsh-hook -d precmd _zsh_zprof_report
# }
# add-zsh-hook precmd _zsh_zprof_report
# --- end zprof report ---
