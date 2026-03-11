---
name: git-read
description: >-
  Always load this skill before using any git command.
---

# Git Exploration Best Practices

## Log

Limit output with `-[n]`, prefer single-line formats unless commit body is needed:

```bash
git log --pretty=lineauthor --date=short --topo-order -10
git log --oneline -20
git log --oneline --graph --decorate -15
```

## General Rules

- Never use `git -C`
- Prefer `--oneline` log output unless commit body is needed
- Use `--stat` before full diffs to gauge scope
- prefer using origin/HEAD when trying to compare with default branch
