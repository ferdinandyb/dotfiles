---
name: gcli
description: Use gcli for non-GitHub git forges (GitLab, Gitea, Codeberg) — viewing/listing/creating PRs/MRs and issues, diffs, CI checks, and forge API calls. For GitHub work, use gh instead. Load whenever interacting with GitLab, Gitea, or Codeberg from the command line, or when the user explicitly asks for gcli.
---

# gcli

CLI tool for non-GitHub git forges (GitLab, Gitea, Codeberg). For GitHub,
agents should use `gh` directly. Keep `gcli` around for non-GitHub work, or
when explicitly requested.

Source lives at `~/softwarefromsource/gcli`, binary at `~/.local/bin/gcli`,
accounts are configured in `~/.config/gcli/config` (contains secrets — never
read it).

## Two things to know first

**1. Markdown rendering is already disabled.** By default gcli renders bodies
through liblowdown, which reflows text and *silently eats underscores* —
`accounts_cards` comes back as `accountscards`, corrupting identifiers and
paths. `~/.config/opencode/plugins/gcli-env.ts` sets `GCLI_RENDER_MARKDOWN=0`
for every agent shell, so raw text comes back as-is.

Do **not** pass the equivalent `--no-markdown` flag. gcli only accepts global
flags *before* the subcommand (`gcli --no-markdown pulls …`), which shifts the
command string past every `gcli pulls …` permission rule and forces a prompt
on each call. Same for `-q`, `-t` and `-a`: avoid them unless needed. If output
does come back reflowed, the plugin is not loading — say so rather than
reaching for the flag.

**2. There is no `--json`.** Output is human-readable tables. When structured
data is needed, use `gcli api` (see [JSON](#json)).

## Invocation shape

```
gcli [global-overrides] <subcommand> [forge-path] [flags] [-i ID] [actions...]
```

- Global overrides (`-q`, `-t <forge>`, `-a <account>`, `-v`) come *before* the
  subcommand — and cost a permission prompt each time. Omit them by default.
- `forge-path` is an optional shorthand right after the subcommand:
  `gh:owner/repo`, `gl:owner/repo`, `cb:owner/repo`, or `account:owner/repo`.
  Equivalent to `-o owner -r repo` (+ forge selection).
- Otherwise owner/repo/forge are inferred from the git remote of the cwd.
  This works with SSH remotes.
- `pr` is a built-in alias for `pulls`.
- Multiple actions can be chained in one call: `-i 42 status comments ci`.

**PR/issue URLs are not accepted as arguments.** Extract the number:
`https://github.com/signifyd/data-science/pull/11316` → `-i 11316`.

## gh → gcli

Read paths:

| gh | gcli |
| --- | --- |
| `gh pr view N` | `gcli pulls -i N all` |
| `gh pr view N --json title,body` | `gcli pulls -i N status op` |
| `gh pr diff N` | `gcli pulls -i N diff` |
| `gh pr view N --json files --jq '.files[].path'` | `gcli pulls -i N diff \| grep '^+++'` |
| `gh pr view N --json commits` | `gcli pulls -i N commits` |
| `gh pr checks N` | `gcli pulls -i N ci` |
| `gh pr view N --comments` | `gcli pulls -i N comments` |
| `gh pr view N --json reviews` | `gcli pulls -i N reviews` |
| `gh api repos/O/R/pulls/N/comments` | `gcli pulls -i N discussions` |
| `gh pr list` | `gcli pulls` |
| `gh pr list --state all` | `gcli pulls -a` |
| `gh pr list --limit 50` | `gcli pulls -n 50` (`-n -1` = all) |
| `gh pr list --search "FEL-235"` | `gcli pulls -a "FEL-235"` |
| `gh pr list --author @me` | `gcli pulls -A <username> -n 100` (see caveat) |
| `gh pr list --label bug` | `gcli pulls -L bug -n 100` |
| `gh pr checkout N` | `gcli pulls -i N checkout` |
| `gh issue view N` | `gcli issues -i N all` |
| `gh issue view N --comments` | `gcli issues -i N all comments` |
| `gh issue list` | `gcli issues` |
| `gh issue list --state all` | `gcli issues -a` |
| `gh issue list --assignee X` | `gcli issues -S X -n 100` |
| `gh api <path>` (GET) | `gcli api <path>` |
| `gh api <path> --paginate` | `gcli api -a <path>` |
| `gh pr status` / `gh status` | `gcli status -l` |

`discussions` is the best replacement for the `gh api .../pulls/N/comments`
habit: it prints threaded review comments with their file and diff hunk, in
one call, no jq.

**`-A`/`-L`/`-M`/`-S` filter client-side on GitHub.** gcli fetches `-n` items
then filters. With the default `-n 30` an author filter only scans the 30 most
recent PRs. Pass a generous `-n` (100+) when filtering, or use a server-side
search term instead. There is no `@me` — use the literal username
(e.g. `benceferdinandy-signifyd`).

`gcli issues` on GitHub silently drops PRs from the listing and prints a note
about it; `-q` suppresses the note.

## Write operations (non-interactive)

Every gcli write path opens `$GIT_EDITOR`/`$VISUAL`/`$EDITOR` on a temp file
and then asks for confirmation. Two mechanisms make that scriptable:

- `GIT_EDITOR=<skill>/scripts/body-editor.sh` with `GCLI_BODY_FILE=<file>`
  stuffs the file contents in as the body. (`EDITOR="cp foo.md"` does *not*
  work — gcli `execlp`s the value as a single program name.)
- `-y` skips the confirmation. Where a command has no `-y`, pipe `printf 'y\n'`
  into it.

Lines starting with `!` are stripped from the body — do not begin a body line
with `!`.

Write the body to a temp file with the Write tool first, then:

```sh
export GCLI_BODY_FILE=$TMPDIR/pr-body.md
export GIT_EDITOR=~/.config/opencode/skills/gcli/scripts/body-editor.sh
```

| gh | gcli |
| --- | --- |
| `gh pr create --title T --body-file B` | `gcli pulls create -T "$GCLI_BODY_FILE" -y "T"` |
| `gh pr create --draft` | add `-d` |
| `gh pr create --base X --head Y` | add `-t X -f Y` |
| `gh pr create --reviewer U` | add `-R U` (repeatable) |
| `gh pr edit N --title T` | `gcli pulls -i N title "T"` |
| `gh pr edit N --body-file B` | `printf 'y\n' \| gcli issues -i N edit` (see below) |
| `gh pr comment N --body-file B` | `gcli comment -p N -y` |
| `gh issue comment N --body-file B` | `gcli comment -i N -y` |
| `gh api .../comments/ID/replies -f body=…` | `gcli comment -p N -R ID -y` |
| `gh pr edit N --add-label L` | `gcli pulls -i N labels add L` |
| `gh pr merge N --squash` | `gcli pulls -i N merge --squash` |
| `gh pr review --approve` | `gcli pulls -i N approve -y` |
| `gh pr close N` / `reopen` | `gcli pulls -i N close` / `reopen` |
| `gh issue create --title T` | `gcli issues create -T "$GCLI_BODY_FILE" -y "T"` |
| `gh issue close N` | `gcli issues -i N close` |

Notes:

- `pulls create` needs a base branch: `-t <branch>`, or `pr.base` in the repo's
  `.gcli` file. It errors out rather than guessing.
- `pulls create -T file` only *pre-fills* the editor; the editor still runs, so
  `GIT_EDITOR` must be set to the body-editor script (or `true` to accept the
  template verbatim).
- **PR body edits**: gcli has no `body` action on `pulls`, but GitHub treats PRs
  as issues, and `gcli issues -i <PR-number>` addresses a PR fine (verified for
  reads). So `issues -i N edit` replaces the PR body. It has no `-y`, hence the
  `printf 'y\n' |` pipe. This particular write is *unverified* — confirm the
  result with `gcli pulls -i N op` afterwards, or just use
  `gh pr edit` if the stakes are high.
- Interactive review (annotate the diff in an editor, then approve / request
  changes) is `gcli pulls -i N review`, gated behind
  `GCLI_ENABLE_EXPERIMENTAL=yes`. It is for humans, not agents.

## JSON

`gcli api <path>` performs a **GET** against the current forge's API base and
dumps raw JSON. Pipe to `jq`. The base URL is prepended, so paths start at
`/repos/...` for GitHub.

```sh
gcli api /repos/signifyd/data-science/pulls/11316 | jq '{number,title,draft,mergeable_state}'
gcli api -a /repos/signifyd/data-science/pulls/11316/files | jq -r '.[].filename'
```

`-a` follows pagination. There is no way to POST/PATCH — for writes use the
gcli subcommands above, or `gh api`.

## Gaps

No gcli equivalent; keep using `gh`:

- `gh run list` / `gh run view --log-failed` — GitHub Actions runs and logs.
  `gcli pulls -i N ci` lists check runs and their IDs, and
  `gcli api /repos/O/R/actions/runs/<id>/jobs` works, but log download does not.
- `gh workflow list|view`
- `gh search code`, `gh search issues` (PR/issue *listing* search terms work:
  `gcli pulls -a "query"`)
- `gh api` with a method other than GET
- `gh repo gitignore|license`
- `gcli pipelines` is GitLab CI only, not GitHub Actions.
