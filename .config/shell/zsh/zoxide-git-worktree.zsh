# Worktree-aware zoxide functions
# zw  - like z, but rewrites paths to stay within current git worktree
# zwi - like zi (interactive), with same worktree awareness
#
# When inside a git worktree and the zoxide match is under ANY worktree of the
# same repo, the path is rewritten to the equivalent location in the CURRENT
# worktree. Falls back to normal behavior if not in a repo or if the rewritten
# path doesn't exist.

__zw_rewrite_path() {
    _zw_result="$1"

    # Get current worktree root
    _zw_current_wt=$(git rev-parse --show-toplevel 2>/dev/null) || {
        printf '%s' "$_zw_result"
        return
    }

    # Get all worktree paths
    _zw_worktrees=$(git worktree list --porcelain 2>/dev/null | grep '^worktree ' | cut -d' ' -f2-)

    # Check each worktree (using newline as delimiter)
    echo "$_zw_worktrees" | while IFS= read -r _zw_wt; do
        [ -z "$_zw_wt" ] && continue
        case "$_zw_result" in
            "$_zw_wt"/*)
                _zw_relative="${_zw_result#$_zw_wt/}"
                _zw_rewritten="$_zw_current_wt/$_zw_relative"
                if [ -d "$_zw_rewritten" ]; then
                    printf '%s' "$_zw_rewritten"
                    return
                fi
                ;;
            "$_zw_wt")
                # Exact match to a worktree root - go to current worktree root
                if [ -d "$_zw_current_wt" ]; then
                    printf '%s' "$_zw_current_wt"
                    return
                fi
                ;;
        esac
    done

    # No rewrite needed or possible, return original
    printf '%s' "$_zw_result"
}

# Worktree-aware z
zw() {
    # Handle special cases like z does
    if [ $# -eq 0 ]; then
        z
        return
    elif [ $# -eq 1 ] && [ "$1" = "-" ]; then
        z -
        return
    elif [ $# -eq 1 ] && [ -d "$1" ]; then
        cd -- "$1"
        return
    fi

    # Check if we're in a git repo
    if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
        z "$@"
        return
    fi

    # Query zoxide
    _zw_query_result=$(zoxide query --exclude "$PWD" -- "$@") || return $?

    # Rewrite path if needed and cd
    _zw_target=$(__zw_rewrite_path "$_zw_query_result")
    cd "$_zw_target"
}

# Worktree-aware zi (interactive)
zwi() {
    # Check if we're in a git repo
    if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
        zi "$@"
        return
    fi

    # Query zoxide interactively
    _zw_query_result=$(zoxide query --interactive -- "$@") || return $?

    # Rewrite path if needed and cd
    _zw_target=$(__zw_rewrite_path "$_zw_query_result")
    cd "$_zw_target"
}
