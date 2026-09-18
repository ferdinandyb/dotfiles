@~/.config/agents/tmux.md
@~/.config/agents/directives.md

Current user is Bence Ferdinandy.

# Only include references available to everyone

Untracked plan files, the contents, plans, phases of untracked plan files,
taskagent tasks must not be referenced in any documentation, code, ticket that
will be viewed by other people. E.g. committed files should never reference
them, jira tickets should not reference them.

# Minimal comments and changes

Reasoning for the code (the why) belongs in commit messages, not comments,
unless the piece of code is extremely non-trivial or has magic strings/numbers.
If you can do something with smaller changes with the same effect, prefer that.
Do not build what we don't need now.

# SKILLS

Many specific tools or situations have an associated skill, always consider
loading relevant skills, e.g. always load the git-read skill before using git.

At session start, if the cwd or branch name contains a ticket ID (e.g. `FEL-123`),
a plan file is present, or the work will span sessions, load the taskagent skill
before proceeding.

# CRITICAL: Python Edits

Formatters (ruff) run after EVERY edit. They WILL delete unused imports.

**RULE**: When adding an import, you MUST ALWAYS first add the USAGE, and only add the import in a subsequent edit.

WRONG (import gets deleted):

- Edit 1: add `import pandas as pd`
- Edit 2: add `df = pd.DataFrame()`

CORRECT (usage first):

- Edit 1: add `df = pd.DataFrame()`
- Edit 2: add `import pandas as pd`

**NEVER** work around ruff stripping imports by assigning them to a dummy
variable or tuple, e.g.:

```python
# UNACCEPTABLE workaround — do not do this
_KEEP = (SomeImport, AnotherImport)
```

This is dead code and will be treated as a bug. The correct fix is always to
ensure the import has a real usage before adding it (see rule above).


# shell tools

I prefer ugrep (ug) over grep, and fd-find (fd) over find.

# personal config

I use `yadm` for my dotfiles. There is a README for it at ~/README.md
`yadm` is a drop in replacement for `git` that uses my dotfiles repo.

# nvim context

If `$NVIM` is set, this session is running under a neovim instance -- see the
`nvim-context` skill for reading cursor position/visual selection or opening
files/quickfix lists in it.

# data

Avoid reading large data files directly, to preserve context. Delegate it to a subagent or use tools like ugrep, ripgrep or jq.

# bash tool

NEVER prepend cd to a command if you are already in the same directory. Resolve shorthands like `~` and `$HOME` when determining this.

When you do need a different directory, use the bash tool's `workdir` parameter instead of `cd` or `git -C <dir>`. Don't pass `git --no-pager` either — bash is non-interactive, so git never paginates.

Prefer the dedicated tools over shelling out: use Read for file contents instead of `cat`/`head`/`tail`. (For search, the `# shell tools` preference for `ug`/`fd` still applies.)

Never redirect output (`>`, `>>`) into files outside `$TMPDIR` (or `/tmp/opencode`) — such redirects are blocked.

Prefer separate, focused tool calls — and run independent ones in parallel — over chaining many commands into a single bash call with `echo "=== … ==="` section headers. Batching collapses many permission decisions into one approval and hurts reviewability.

# cloned software

For reference many opencode repositories are pulled to `~/softwarefromsource`
or ~`/.local/softwarefromsource`. When looking for documentation, always look
here as well.
