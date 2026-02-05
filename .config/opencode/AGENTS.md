@~/.config/agents/tmux.md
@~/.config/agents/directives.md

# CRITICAL: Python Edits

Formatters (ruff) run after EVERY edit. They WILL delete unused imports.

**RULE**: When adding an import, you MUST ALWAYS first add the USAGE, and only add the import in a subsequent edit.

WRONG (import gets deleted):

- Edit 1: add `import pandas as pd`
- Edit 2: add `df = pd.DataFrame()`

CORRECT (usage first):

- Edit 1: add `df = pd.DataFrame()`
- Edit 2: add `import pandas as pd`


# shell tools

I prefer ugrep (ug) over grep, and fd-find (fd) over find.

# personal config

I use `yadm` for my dotfiles. There is a README for it at ~/README.md
`yadm` is a drop in replacement for `git` that uses my dotfiles repo.

# nvim mcp

Check the cursor position and visual select in nvim for possibly important context.

# data

Avoid reading large data files directly, to preserve context. Delegate it to a subagent or use tools like ugrep, ripgrep or jq.

# bash tool

NEVER prepend cd to a command if you are already in the same directory. Resolve shorthands like `~` and `$HOME` when determining this.
