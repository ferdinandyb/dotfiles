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

- Never use `git -C`
- Prefer `--oneline` log output unless commit body is needed
- Use `--stat` before full diffs to gauge scope
- prefer using `origin/HEAD` when trying to compare with default branch
