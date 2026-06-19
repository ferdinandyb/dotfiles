---
name: git-read
description: >-
  MUST load before ANY git or yadm operation — reading, writing, branching,
  committing, diffing, logging, rebasing, or anything else git-related. No
  exceptions.
---

# Git Exploration Best Practices

## Log

Limit output with `-[n]`, prefer single-line formats unless commit body is needed:

```bash
git log --pretty=lineauthor --date=short --topo-order -10
git log --oneline -20
```

## Stacked PR-s

Use

```
git log --oneline --graph --branches --remotes -20
```

to help detect stacked PR-s. A naming convention of `TOPIC-part-N` may or may
not apply.

## General Rules

- Never use `git -C <dir>` — set the bash tool's `workdir` parameter instead and run plain `git …`.
  (The read-only verbs are allow-listed; the `git -C …` form is not, so it prompts.)
- Don't pass `git --no-pager` — the bash tool is non-interactive, so git never paginates anyway.
  Plain `git log`/`git diff`/`git show` are allow-listed; the `git --no-pager …` form is not.
- Prefer `--oneline` log output unless commit body is needed
- Use `--stat` before full diffs to gauge scope
- prefer using `origin/HEAD` when trying to compare with default branch

## Reading files at a specific commit (no checkout)

These commands read file contents from any commit without touching the working
tree. No checkout, no detached HEAD, safe in dirty repos or when we're
interested in the contents of another branch, then what we're on.

### Cat a file at a ref

```bash
git show <ref>:<path>          # dump file at a commit, branch, or tag
git show HEAD~3:src/Foo.java   # three commits back
git show origin/main:README.md # from a remote branch
git show abc1234:config/app.yml
```

`:<path>` (no ref prefix) reads from the index (staging area), not the working
tree.

Low-level alternative — same output, useful in scripts:
```bash
git cat-file -p <ref>:<path>
```

**Gotcha**: `git show ref path` (space) shows the diff a commit made to a file.
`git show ref:path` (colon) dumps the file contents. Always use the colon form
to read contents.

**Gotcha**: `<path>` must be repo-root-relative and must **not** start with `/`.

### Grep at a ref

```bash
git grep -n <pattern> <ref>               # search entire tree at that commit
git grep -n <pattern> <ref> -- <pathspec> # narrow to a subtree or file
git grep -in "TODO" HEAD~10 -- src/       # case-insensitive, older commit
git grep -l "FeatureFlag" origin/main     # filenames only
git grep -C2 "getUser" abc1234            # 2 lines of context
```

Bare `git grep <pattern>` searches the working tree — adding a ref switches to
that commit's snapshot.

Multiple commits at once:
```bash
git grep "deprecated" HEAD HEAD~5 HEAD~10
```

### List a tree at a ref

```bash
git ls-tree --name-only <ref> <dir>/   # one level (like ls)
git ls-tree -r --name-only <ref>       # recursive (like find)
git ls-tree -r --name-only HEAD src/   # recursive under a subtree
```

### File history and diffs without checkout

```bash
# commits that touched a file, reachable from a ref
git log --oneline <ref> -- <path>
git log --oneline origin/main -- src/foo.c

# what a specific commit changed in one file
git show <commit> -- <path>

# diff one file across two commits
git diff <c1> <c2> -- <path>
git diff HEAD~5 HEAD -- src/foo.c

# blame as of a specific ref
git blame <ref> -- <path>
git blame origin/main -- src/foo.c
```

### Find which commit introduced or changed a string (pickaxe)

Use pickaxe to locate the ref, then read with `git show ref:path`.

```bash
# commits that added or removed occurrences of a string
git log -S"getUserToken" --oneline

# show the diff too, scoped to a path
git log -S"getUserToken" -p -- src/

# treat the term as a regex
git log -S"get.*Token" --pickaxe-regex --oneline

# commits whose diff contains a line matching the regex (any change, not just add/remove)
git log -G"getUserToken" --oneline
```

- `-S` — change in *count* of the string: finds where it was added or removed. Fixed-string by default; add `--pickaxe-regex` for regex.
- `-G` — diff line *matches* the regex: finds every commit that touched it, even if the count didn't change.
