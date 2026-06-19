---
name: taskagent
description: >-
  Load before ANY taskagent operation, or when you read a file referencing
  taskagent (org/projects, plan files, docs). taskagent is the human-facing
  backlog and durable cross-session memory — not in-session working memory.
  For steps you'll finish this session, use TodoWrite + the plan file.
---

# Taskagent - Shared Work Tracker

## What taskagent is for

taskagent serves two purposes:
1. **The human's view** — backlog of deliverables, what is active, what is done.
2. **Durable cross-session memory** — `LEARNING` / `MISALIGNMENT` notes and
   handoff state that must outlive the conversation.

It is not your in-session working memory. Sessions can carry a large amount of
work, so tracking your own place within a task belongs in TodoWrite, and the
design/spec of a task belongs in the plan file.

### Where things live

| Tool            | Holds                                                         | Lifetime                 |
| --------------- | ------------------------------------------------------------- | ------------------------ |
| **TodoWrite**   | This session's tactical steps                                 | The session              |
| **plan file**   | Design, spec, wiring, current state of a ticket               | The ticket / worktree    |
| **agentmemory** | Auto-captured, searchable observations                        | Long-term, searchable    |
| **taskagent**   | Human-facing backlog + status + durable LEARNING/MISALIGNMENT | Long-term, human-curated |

## When to create a taskagent task

Create a task when it is:
- A deliverable at PR / ticket / epic granularity the human would track, or
- Work that will outlive this session and needs pickup later, or
- **Offshoot work surfaced mid-session that is not part of the current
  deliverable but should be remembered** — a bug noticed in passing, a refactor
  opportunity, a follow-up, a side quest.

That last case is one of taskagent's most valuable uses: it moves the thought
out of the volatile session and into the human's backlog without derailing
current work. Use `discovered_from:<parent_uuid>` and/or `+side_quest`. Do not
park such work in TodoWrite — TodoWrite dies with the session.

Otherwise, default to **not** creating a task. In-session steps go to TodoWrite.

## Anti-pattern: pre-decomposing one deliverable

Do not shatter a single deliverable into a tree of taskagent subtasks with
implementation specs in the annotations. That structure is not read across
sessions, adds no durable memory, and ends up deleted. Keep one task per
deliverable; put the steps in TodoWrite and the spec/wiring in the plan file.
Reserve annotations for durable `LEARNING` / `MISALIGNMENT` and handoff state.

If you are about to create more than a couple of tasks for work that completes
in this session, stop — that is TodoWrite plus a plan file.

## CRITICAL: Command Name

**Always use `taskagent`, NEVER use `task` directly.**

`taskagent` is a hardened wrapper that shares the human's taskwarrior database
(`~/.task`) but enforces that the agent may only **modify** tasks tagged
`+agent`. Reads of any task are allowed. Using `task` directly is denied by
opencode permissions. **`taskagent` is globally available** — works from
anywhere, no `cd` needed.

## CRITICAL: +agent tag and write access

Every task the agent creates is **automatically tagged `+agent`** by an on-add
hook. The agent may only modify/done/delete/annotate `+agent` tasks; modifying a
human task is rejected at the taskwarrior layer. The `+agent` tag is **sticky**.
Default views (`list`, `ready`, `next`) are filtered to `+agent`. To read a
human task, use its UUID directly:
```bash
taskagent <uuid> info          # reads any task, including human tasks
taskagent <uuid> agentinfo     # same, minimal format
```
**Forbidden** (blocked by the wrapper): `undo`, `config`, `execute`, any `rc:`
or `rc.*` overrides.

## CRITICAL: Use Partial UUIDs, Not Short IDs

Short IDs (1, 2, 3…) renumber when tasks complete/delete. Use the first 8 chars
of the UUID — permanent and shown as `uuid.short` in all reports.
```bash
taskagent abc1234d info        # GOOD — stable partial UUID
taskagent 3 info               # BAD — short ID may change
```
When creating tasks, capture the UUID from the output for future references.

## Status

Keep status current so the human's `taskagent +ACTIVE list` reflects reality:
```bash
taskagent <uuid> start   # began this deliverable
taskagent <uuid> stop    # paused it
taskagent <uuid> done    # complete — after review (see below)
```

## Recording Learnings and Misalignments

This is the highest-value content taskagent stores. Annotate as they occur:

**LEARNING** = new durable info (user preference, codebase pattern, correct approach)
```bash
taskagent <uuid> annotate "LEARNING: <fact and where it applies>"
```
**MISALIGNMENT** = wrong direction taken and corrected (wasted effort)
```bash
taskagent <uuid> annotate "MISALIGNMENT: <what went wrong and the correction>"
```
A misalignment often produces a learning — record both. These are retrieved
during `/handoff` and written to the plan file's `## Learnings` section.

**Which store:** ticket-specific context → a taskagent annotation on the
deliverable (surfaced when that task is read, and via `/handoff` into the plan
file). Reusable insight that applies beyond this ticket — codebase convention,
tool preference, recurring pitfall → also call `memory_lesson_save`, so
agentmemory auto-injects it into future sessions. taskagent annotations don't
decay; agentmemory lessons do if unused.

## Checkpointing (only when state must survive)

Annotate progress only when the state needs to outlive the conversation:
approaching compaction, ending a session mid-deliverable, or blocked. Do not
annotate at every milestone within a session.

Write for a reader with zero conversation context:
```
COMPLETED: <deliverables>  IN PROGRESS: <state + next step>  BLOCKERS: <…>  KEY DECISIONS: <…>
```

## Session Start Protocol

1. `taskagent ready` — unblocked work.
2. `taskagent +ACTIVE list` — anything left active.
3. For active/relevant work: `taskagent <uuid> agentinfo` (or `info`).
4. If the project is unclear, ask; then check `~/org/projects/<project>.md`
   `## Agent` section for `taskagent project` and `plan file`.
5. Read the plan file if it exists.
6. Report: "X ready, Y active. [summary]. Continue with Z?"

## Core Operations

> Run basic ops (add, annotate, modify, start, stop, list, info) directly — no
> subagent. Use `@task-reviewer` for completion review and `@taskagent-reader`
> for complex queries. For code review, ask the user to run `/peerreview`.

```bash
taskagent ready                         # unblocked tasks
taskagent project:<name> ready
taskagent blocked                       # blocked by deps
taskagent blocking                      # blocking others

taskagent add "Title" project:<name>
taskagent add "Title" project:<name> details:"context / why"
taskagent add "Found issue" project:<name> discovered_from:<parent_uuid>

taskagent <uuid> start | stop | done
taskagent <uuid> annotate "LEARNING: …"
taskagent <uuid> modify depends:<other_uuid>
taskagent <uuid> agentinfo | info
taskagent project:<name> list
```

## Task Fields Reference

| Field                                                      | Purpose                                             | When            |
| ---------------------------------------------------------- | --------------------------------------------------- | --------------- |
| **description**                                            | Short title                                         | At creation     |
| **details**                                                | Initial context, the "why" (not the full spec)      | At creation     |
| **project**                                                | Links to org/projects                               | At creation     |
| **annotations**                                            | Durable LEARNING/MISALIGNMENT + handoff (not specs) | During work     |
| **discovered_from**                                        | Parent task UUID                                    | When discovered |
| **+side_quest / +bug / +feature / +task / +chore / +epic** | Classification                                      | At creation     |

## Completion Review (per deliverable, not per micro-task)

Invoke `@task-reviewer` once per deliverable-sized task (the PR/ticket) before
`taskagent <uuid> done`. A separate review for every small sub-item is not
required — review the thing that ships.

For externally-tracked work (Jira/GitHub):
1. **Before PR/merge**: ask the user to run `/peerreview <ticket-ID|PR-number>`
   (launches `code-reviewer-opus` + `code-reviewer-gemini` as children of root —
   do not spawn `@code-reviewer` yourself).
2. **Before `done`**: invoke `@task-reviewer`.

Invoke with the UUID:
```
@task-reviewer Review task <uuid>
- Project: <name>   - plan file: <path or none>   - org/projects: <path or none>
- Summary: <1-2 sentences>   - Key files: <list or none>
```
Verdicts: **PASS** → may `done`. **PASS WITH RESERVATIONS** → ask the human.
**NEEDS WORK** → fix and re-review.

## What survives, what doesn't

- **Survives**: taskagent data, `org/projects/*.md`, agentmemory, and the
  project plan file when it lives outside a per-ticket worktree.
- **Does not survive**: conversation history and TodoWrite. A plan file that
  lives inside a throwaway worktree only survives as long as that worktree does.

Keep the plan file at a durable, project-level location (configured in
`org/projects`), not inside a worktree that may be removed. If a decision or
lesson must outlive any single worktree, also record it as a taskagent
`LEARNING` or in the `org/projects` file.

## Integration with TodoWrite

- **TodoWrite**: this session's tactical steps; your own checklist.
- **taskagent**: deliverables, status, durable lessons, offshoot work to
  remember.

At session start, read the relevant taskagent task and expand it into a
TodoWrite checklist. Work, ticking TodoWrite. At a real boundary, record a
LEARNING/handoff annotation and update status. Do not mirror every TodoWrite
item as a taskagent task.

## Plan file & org/projects

The project plan file holds the design, spec, wiring, and current state of the
work. Keep it at a durable, project-level path (outside per-ticket worktrees) so
it persists across tickets and sessions. The `org/projects/<project>.md`
`## Agent` section configures it:
```markdown
## Agent
- **taskagent project**: `project-name`
- **plan file**: `~/path/to/plan.md`
```
`taskagent project` defaults to the filename; `plan file` defaults to `PLAN.md`
in the repo root. Read it at session start; update its `## Notes` /
`## Learnings` with significant progress (ask before editing `## Current Focus`).
