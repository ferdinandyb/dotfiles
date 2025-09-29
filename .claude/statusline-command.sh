#!/bin/bash

# Read Claude Code input
input=$(cat)

# Extract information from Claude Code input
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')

# Change to the current working directory for git operations
cd "$cwd" 2>/dev/null || cd "$HOME"

# Color codes (using 256 color palette like your promptline theme)
# Section a: Git branch and virtual env (purple background)
a_fg='\033[38;5;236m'    # dark gray foreground
a_bg='\033[48;5;141m'    # purple background
a_sep_fg='\033[38;5;141m' # purple separator

# Section b: SSH user (dark blue background)  
b_fg='\033[38;5;253m'    # light gray foreground
b_bg='\033[48;5;61m'     # dark blue background
b_sep_fg='\033[38;5;61m' # dark blue separator

# Section c: Current directory (dark gray background)
c_fg='\033[38;5;253m'    # light gray foreground
c_bg='\033[48;5;239m'    # dark gray background
c_sep_fg='\033[38;5;239m' # dark gray separator

# Warning section: Exit code (orange background)
warn_fg='\033[38;5;236m'   # dark gray foreground
warn_bg='\033[48;5;215m'   # orange background
warn_sep_fg='\033[38;5;215m' # orange separator

# Reset and separators
reset='\033[0m'
reset_bg='\033[49m'
sep=''  # Powerline separator
space=' '

# Helper function to get git branch
get_git_branch() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch
        if branch=$(git symbolic-ref --quiet HEAD 2>/dev/null); then
            branch=${branch##*/}
            printf " %s" "$branch"
        elif branch=$(git rev-parse --short HEAD 2>/dev/null); then
            printf " %s" "$branch"
        fi
    fi
}

# Helper function to format current directory (replicating your promptline logic)
format_cwd() {
    local dir_limit=3
    local truncation="⋯"
    local first_char
    local part_count=0
    local formatted_cwd=""
    local dir_sep="  "
    local tilde="~"
    
    local current_cwd="${cwd/#$HOME/$tilde}"
    
    # Get first char
    first_char="${current_cwd:0:1}"
    
    # Remove leading tilde
    current_cwd="${current_cwd#\~}"
    
    while [[ "$current_cwd" == */* && "$current_cwd" != "/" ]]; do
        # Pop off last part of cwd
        local part="${current_cwd##*/}"
        current_cwd="${current_cwd%/*}"
        
        formatted_cwd="$dir_sep$part$formatted_cwd"
        part_count=$((part_count+1))
        
        [[ $part_count -eq $dir_limit ]] && first_char="$truncation" && break
    done
    
    printf "%s" "$first_char$formatted_cwd"
}

# Build the statusline
statusline=""
is_empty=1

# Section a: Git branch and virtual environment
git_branch=$(get_git_branch)
virtual_env=""
if [[ -n "$VIRTUAL_ENV" ]]; then
    virtual_env="${VIRTUAL_ENV##*/}"
fi

section_a_content=""
if [[ -n "$git_branch" ]]; then
    section_a_content="$git_branch"
fi
if [[ -n "$virtual_env" ]]; then
    if [[ -n "$section_a_content" ]]; then
        section_a_content="$section_a_content$space$virtual_env"
    else
        section_a_content="$virtual_env"
    fi
fi

if [[ -n "$section_a_content" ]]; then
    statusline="${statusline}${a_bg}${sep}${a_fg}${a_bg}${space}${section_a_content}${space}${a_sep_fg}"
    is_empty=0
fi

# Section b: SSH user (only if SSH connection)
if [[ -n "$SSH_CLIENT" ]]; then
    user=$(whoami)
    if [[ $is_empty -eq 1 ]]; then
        statusline="${statusline}${b_fg}${b_bg}${space}${user}${space}${b_sep_fg}"
    else
        statusline="${statusline}${b_bg}${sep}${b_fg}${b_bg}${space}${user}${space}${b_sep_fg}"
    fi
    is_empty=0
fi

# Section c: Current directory
formatted_dir=$(format_cwd)
if [[ $is_empty -eq 1 ]]; then
    statusline="${statusline}${c_fg}${c_bg}${space}${formatted_dir}${space}${c_sep_fg}"
else
    statusline="${statusline}${c_bg}${sep}${c_fg}${c_bg}${space}${formatted_dir}${space}${c_sep_fg}"
fi

# Close sections and add Claude Code info
statusline="${statusline}${reset_bg}${sep}${reset}${space}│${space}${model_name}"

if [[ "$output_style" != "null" && "$output_style" != "default" ]]; then
    statusline="${statusline}${space}(${output_style})"
fi

# Print the final statusline
printf "%b\n" "$statusline"