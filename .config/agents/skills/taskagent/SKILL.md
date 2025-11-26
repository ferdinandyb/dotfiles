---
name: taskagent
description: Track complex, multi-session agent work using taskwarrior via taskagent. Use when work spans multiple sessions, has dependencies, or requires persistent context across compaction cycles. For simple single-session linear tasks, TodoWrite remains appropriate.
---

# Taskagent - Agent Work Tracking

## Overview

taskagent is a taskwarrior-based tracker for persistent agent memory across sessions. Use for multi-session work with complex context; use TodoWrite for simple single-session tasks.

## When to Use taskagent vs TodoWrite

### Use taskagent when:
- **Multi-session work** - Tasks spanning multiple compaction cycles or days
- **Complex context** - Work needing detailed background or discovered subtasks
- **Project work** - Tasks tied to a specific project with a PLAN.md
- **Side quests** - Exploratory work that might pause the main task
- **Handoff needed** - Work that another session (or human) needs to pick up

### Use TodoWrite when:
- **Single-session tasks** - Work that completes within current session
- **Linear execution** - Straightforward step-by-step tasks with no branching
- **Immediate context** - All information already in conversation
- **Simple tracking** - Just need a checklist to show progress

**Key insight**: If resuming work after 2 weeks would be difficult without taskagent, use taskagent.

## Surviving Compaction Events

**What survives compaction:**
- All taskagent data (tasks, annotations, details, dependencies)
- PLAN.md in project root
- org/projects wiki files

**What doesn't survive:**
- Conversation history
- TodoWrite lists

**Writing annotations for post-compaction recovery:**

Write annotations as if explaining to a future agent with zero conversation context:

```
COMPLETED: Specific deliverables
IN PROGRESS: Current state + next immediate step
BLOCKERS: What's preventing progress
KEY DECISIONS: Important context or user guidance
```

## Session Start Protocol

**At session start, always:**

1. Check for ready work:
   ```bash
   taskagent ready
   ```

2. Check for active (in-progress) work:
   ```bash
   taskagent +ACTIVE list
   ```

3. If active work exists, read the task details and annotations:
   ```bash
   taskagent <id> agentinfo    # minimal info for agents (preferred)
   taskagent <id> info         # full details (shorthand for 'information')
   ```

4. Ask user which project/context if unclear, then check for org/projects file:
   - Look for `~/org/projects/<project>.md` (vimwiki)
   - Read the `## Agent` section for:
     - `taskagent project`: project name (defaults to filename)
     - `plan file`: path to PLAN.md (defaults to repo root)

5. Read the PLAN.md if it exists for additional context

6. Report to user: "X tasks ready, Y in progress. [Summary]. Should I continue with Z?"

## Progress Checkpointing

Update taskagent annotations at these checkpoints:

**Critical triggers:**
- Context running low - User mentions compaction/token limit
- Token budget > 70% - Proactively checkpoint
- Major milestone reached - Completed significant work
- Hit a blocker - Can't proceed, capture what was tried
- Task transition - Switching tasks or closing one

**Checkpoint command:**
```bash
taskagent <id> annotate "COMPLETED: X. IN PROGRESS: Y. NEXT: Z."
```

## Core Operations

### Check ready work (built-in report)
```bash
taskagent ready                    # built-in taskwarrior report, shows unblocked tasks
taskagent project:<name> ready
taskagent blocked                  # show tasks blocked by dependencies
taskagent blocking                 # show tasks that are blocking others
```

### Create new task
```bash
taskagent add "Task title" project:<name>
taskagent add "Task title" project:<name> details:"Longer explanation of context and why"
taskagent add "Task title" project:<name> +side_quest
```

### Link discovered work
```bash
# Use UUID (not short ID) for discovered_from - short IDs can change
taskagent <parent_id> _uuid   # get parent's UUID first
taskagent add "Found issue" project:<name> discovered_from:<parent_uuid>
```

### Update task status
```bash
taskagent <id> start        # marks in progress
taskagent <id> stop         # pauses work
taskagent <id> done         # completes task
```

### Add session notes (annotations)
```bash
taskagent <id> annotate "COMPLETED: auth endpoint. IN PROGRESS: tests. NEXT: integration."
```

### View task details
```bash
taskagent <id> agentinfo    # minimal info for agents (preferred)
taskagent <id> info         # full details (shorthand for 'information')
taskagent project:<name> list
```

### Dependencies
```bash
taskagent <id> modify depends:<other_id>
```

## Task Fields Reference

| Field | Purpose | When to Set |
|-------|---------|-------------|
| **description** | Short task title | At creation |
| **details** | Initial context, the "why" | At creation |
| **project** | Links to org/projects | At creation |
| **annotations** | Session handoff notes | During work, at checkpoints |
| **discovered_from** | Parent task UUID (not short ID) | When discovered during other work |
| **+side_quest** | Tag for exploratory work | At creation if applicable |
| **+bug** | Tag: something broken | At creation |
| **+feature** | Tag: new functionality | At creation |
| **+task** | Tag: work item (tests, docs, refactoring) | At creation |
| **+chore** | Tag: maintenance (dependencies, tooling) | At creation |
| **+epic** | Tag: large feature, group of related tasks | At creation |

## PLAN.md Convention

**Optional**: Projects can have a `PLAN.md` in the repo root. This can be used independently of org/projects files, or together with them.

```markdown
# Project Plan

## Current Focus
What the agent should prioritize right now.

## Context
Background information helpful for the agent.

## Notes
Human-agent collaborative notes, session summaries.
```

The agent should:
- Read PLAN.md at session start for context
- Update the `## Notes` section with significant progress/decisions (ask first)
- Never modify `## Current Focus` without asking

## Task Completion Review

Before marking a task done, invoke @task-reviewer with context you have available:

```
@task-reviewer Review task <id>
- Project: <project-name>
- PLAN.md: <path or "none">
- org/projects file: <path or "none">
- Summary: <what you did in 1-2 sentences>
- Key files changed: <list main files touched>
```

Include whichever fields you have - the reviewer can work with partial context.

Only mark done after addressing feedback or consciously deciding to defer items.

## Integration with TodoWrite

**Temporal layering:**

- **TodoWrite** (this hour): Tactical execution, immediate steps
- **taskagent** (this week/month): Strategic objectives, persistent context

**Handoff pattern:**
1. Session start: Read taskagent task -> Create TodoWrite for immediate actions
2. During work: Mark TodoWrite items completed
3. Reach milestone: Update taskagent annotations
4. Session end: TodoWrite disappears, taskagent survives

## org/projects File Format

**Optional**: The org/projects vimwiki file (`~/org/projects/<project>.md`) can be used independently of PLAN.md, or together with it. Format:

```markdown
# Project Name

## Overview
High-level description.

## Resources
- Links, repos, docs

## Tasks
- [ ] Human tasks

## Agent
- **taskagent project**: `project-name`
- **plan file**: `~/path/to/repo/PLAN.md`
```

If `taskagent project` is omitted, defaults to the filename.
If `plan file` is omitted, defaults to `PLAN.md` in repo root.