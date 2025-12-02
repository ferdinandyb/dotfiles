# Git rules

If you are using git for managing commit for me, you can use your builtin
Bash() thingy. If you want to read the output of a git command for yourself,
always disable the pager by prefixing the command with the appropriate
environment variable. Never try to edit git config yourself. Do not include
emojis in a commit message.

## Git Commit Best Practices

(Summarized from https://bence.ferdinandy.com/gitcraft)

**Commit Message Structure:**
- Title: 50 chars ideal, max 72
- Use scope prefixes (ci:, ui:, train:, etc.)
- Write in imperative mood ("Fix bug" not "Fixed bug")
- Wrap body at 72 characters
- Explain WHY the commit is needed

**Commit Principles:**
- Each commit should be self-contained and change one specific part
- Every commit must produce working code (thus every commit must pass tests and
  linters)
- Use commit trailers when relevant
- Avoid merge commits, prefer rebasing

**Workflow:**
- Stage changes by hunks (git add -p)
- Rewrite history before pushing to shared branches
- Use git commit --amend for recent edits
- Interactive rebase for complex history management

**Benefits:**
- Readable git log/blame
- Simplified code reviews
- Effective debugging with git bisect
- Easier maintenance

## Built-in rules

Apply your builtin git rules as well, but the ones in this file take precendence.

## Safety

You are not allowed to push under any circumstance.
