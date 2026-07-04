function myissues(){
  jira issue list -q "assignee = currentUser() AND resolution is NULL"
}


function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function mdterm() {
	if [[ -n $TMUX ]]; then
		tmux set -p allow-passthrough on
		trap 'tmux set -pu allow-passthrough' EXIT
		# tmux clobbers TERM_PROGRAM to "tmux" for the pane; mdterm can't
		# otherwise tell the outer terminal is Ghostty. Override for now.
		TERM_PROGRAM=ghostty command mdterm "$@"
	else
		command mdterm "$@"
	fi
}

function confed-review() {
	(cd ~/.local/share/yadm/repo.git && tuicr "$@")
}
