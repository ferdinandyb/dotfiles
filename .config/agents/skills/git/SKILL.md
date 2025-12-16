---
name: git
description: >-
  Load this skill when performing git operations that modify repository state
  (add, commit, amend, rebase, merge, stash, worktree, reset, checkout, switch,
  branch create/delete). Not needed for read-only operations like status, log,
  diff, show, or blame.
---

# Git Best Practices for Agents

## Core Principles

### Atomic Commits

- Each commit must be **self-contained** and change **one well-scoped part** of the code
- Each commit must produce **working code** (passes tests and linters)
- A commit can be a single-character change if that change is logically separate
- Multiple commits may touch the same file or even the same line - that's fine if they're logically distinct changes

### Why This Matters

- Makes `git blame` useful for understanding _why_ code exists
- Enables `git bisect` for debugging (only works if every commit is working code)
- Makes `git revert` and `git cherry-pick` practical
- Simplifies code review

## Commit Message Format

### Title

- **50 characters ideal**, max 72
- Use scope prefix: `ci:`, `ui:`, `train:`, `doc:`, `fix:`, `feat:`, etc.
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

# Later, autosquash during rebase
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

### Interactive Rebase

```bash
git rebase -i HEAD~4           # manipulate last 4 commits
git rebase -i origin/main      # manipulate all commits since main
```

Actions: `pick`, `reword`, `edit`, `squash`, `fixup`, `drop`

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
- `git rebase -i` (interactive rebase)
- `git merge` (when it opens editor for merge commit message)
- `git tag -a` (annotated tags without `-m`)

**Workarounds:**
- Use `git commit -m "message"` instead of `git commit`
- Use `GIT_EDITOR=true git rebase --continue` to accept the default message
- For interactive rebases, manually specify the rebase plan or ask the user to handle it

## General Rules

- Disable pager for reading output: `GIT_PAGER= git <command>`
- Never edit git config
- Never push (permission denied)
- Prefer rebasing over merge commits
- Fast-forward merges when possible
