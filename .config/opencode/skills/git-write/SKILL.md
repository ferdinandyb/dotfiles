---
name: git-write
description: >-
  Load this skill when performing git operations that modify repository state:
  add, commit, amend, rebase, merge, stash, worktree, reset, checkout, switch,
  branch create/delete.
---

# Git Write Operations Best Practices

## Core Principles

### Atomic Commits

- Each commit must be **self-contained** and change **one well-scoped part** of
  the code
- Each commit must produce **working code** (passes tests and linters)
- New definitions should be introduced in the same commits that use them.
- Tests for new functionality should be added in the same commit.
- A commit can be a single-character change if that change is logically
  separate
- Multiple commits may touch the same file or even the same line — that's fine
  if they're logically distinct changes

In other words: a commit must be able to become a fully functional pull/merge
request on it's own if needed.


## Commit Message Format

### Title

- **50 characters ideal**, max 72
- Use scope prefix: `ci:`, `doc:`, `accounts:`, `server:`. Do not use
  conventional commit prefixes.
- **Imperative mood**: "Fix bug" not "Fixed bug"
- No emojis

### Body

- Wrap at **72 characters**
- Explain **WHY** the commit is needed (not just what changed)
- Write for a non-senior, recently onboarded colleague
- Use commit trailers when relevant (`Co-authored-by:`, `Fixes:`, `Link:`)

## Fine-Grained Staging

**Never stage entire files blindly.** Use these commands:

| Command        | Purpose                                 |
| -------------- | --------------------------------------- |
| `git add -p`   | Stage by hunks interactively            |
| `git add -e`   | Edit the patch manually (most granular) |
| `git reset -p` | Unstage by hunks (reverse of add -p)    |

This allows splitting unrelated changes in the same file into separate commits.

## Rewriting History

**Before pushing to shared branches**, actively rewrite history to create clean atomic commits.

### Amending the Last Commit

```bash
git add <files>
git commit --amend           # edit message
git commit --amend --no-edit # keep message
```

### Fixup Commits (for older commits)

```bash
# Create a fixup commit targeting a specific commit
git add <files>
git commit --fixup=<commit-hash>

# Later, autosquash during rebase, does not use $EDITOR
git rebase --autosquash origin/main
```

### Splitting a Commit

```bash
# Reset to previous commit, keeping changes in working directory
git reset HEAD^

# Or soft reset to keep changes staged
git reset --soft HEAD^

# Then re-stage selectively with git add -p
```

### Programmatic Rebase (No Editor)

Agents cannot use `git rebase -i` because it opens an interactive editor.
Instead, use `GIT_SEQUENCE_EDITOR` to manipulate the rebase plan
programmatically:

```bash
# Squash the last 2 commits into one
GIT_SEQUENCE_EDITOR="sed -i '2s/^pick/squash/'" git rebase -i HEAD~2

# Drop the 3rd-to-last commit
GIT_SEQUENCE_EDITOR="sed -i '3s/^pick/drop/'" git rebase -i HEAD~3

# Reword a commit (then follow up with git commit --amend -m "new message")
GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/reword/'" git rebase -i HEAD~1

# Fixup all commits except the first (squash without keeping messages)
GIT_SEQUENCE_EDITOR="sed -i '2,\$s/^pick/fixup/'" git rebase -i HEAD~4

# Apply --autosquash (processes fixup!/squash! commits automatically)
git rebase --autosquash origin/main
```

Available actions: `pick`, `reword`, `edit`, `squash`, `fixup`, `drop`

The `GIT_SEQUENCE_EDITOR` command receives the todo file path as its argument.

The `GIT_SEQUENCE_EDITOR` command receives the todo file path as its argument. Use `sed -i` with one or more `-e` expressions (macOS requires `sed -i ''`, Linux uses `sed -i`):

```bash
# Single change (macOS)
GIT_SEQUENCE_EDITOR="sed -i '' '2s/^pick/squash/'" git rebase -i HEAD~3

# Multiple changes — chain with -e
GIT_SEQUENCE_EDITOR="sed -i '' -e '2s/^pick/squash/' -e '3s/^pick/squash/' -e '4s/^pick/drop/'" git rebase -i HEAD~5
```

Line numbers are 1-indexed; line 1 = oldest commit in the range.

### Recovering After Rebase

- `ORIG_HEAD` references the commit before rebase
- `git reflog` shows all recent commits, even "lost" ones
- `git range-diff ORIG_HEAD~4..ORIG_HEAD HEAD~4..HEAD` to compare before/after

## Workflow Summary

1. **Make changes** in working directory
2. **Stage selectively** with `git add -p` (not `git add .` or `git add -A`)
3. **Commit atomically** with good message explaining WHY
4. **Amend/fixup** as you iterate
5. **Rebase and clean up** before pushing to shared branches

## Commands That Open $EDITOR

Some git commands open `$EDITOR` for interactive input. **Agents CANNOT run these commands directly** because they require interactive text editor input.

Examples:

- `git commit` (without `-m` or `--message`)
- `git rebase --continue` (when fixing conflicts and editor opens for commit message)
- `git merge` (when it opens editor for merge commit message)
- `git tag -a` (annotated tags without `-m`)

**Workarounds:**

- Use `git commit -m "message"` instead of `git commit`
- Use `GIT_EDITOR=true git rebase --continue` to accept the default message
- For interactive rebases, use `GIT_SEQUENCE_EDITOR` to programmatically edit the rebase plan (see "Programmatic Rebase" section above)

## General Rules

- Never edit git config
- Never push (permission denied)
- Prefer rebasing over merge commits
- Fast-forward merges when possible
