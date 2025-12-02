# Agentic Workflow Guide

This document explains how to use the taskagent-based workflow for AI coding agents.

## Overview

The system consists of:
- **taskagent** - A taskwarrior instance dedicated to agent work tracking
- **taskagent skill** - Instructions for agents on how to use taskagent
- **task-reviewer subagent** - A grumpy reviewer that checks work before completion
- **taskagent-reader subagent** - Read-only analyst for querying taskagent database
- **`/handoff` command** - Structured session handoff with learnings capture
- **org/projects files** - Human-maintained project context (vimwiki)
- **PLAN.md** - Per-project plan file for human-agent collaboration

## For Humans: Setting Up a Project

### 1. Create an org/projects entry

Create or edit `~/org/projects/<project-name>.md`:

```markdown
# Project Name

## Overview
What this project is about.

## Resources
- [[related-wiki-pages]]
- [External docs](https://...)
- Repo: `~/path/to/repo`

## Tasks
- [ ] Human tasks go here
- [ ] Things to review

## Agent
- **taskagent project**: `my-project`
- **plan file**: `~/path/to/repo/PLAN.md`
```

The `## Agent` section tells the agent:
- Which taskagent project to use (defaults to filename if omitted)
- Where the PLAN.md lives (defaults to repo root if omitted)

### 2. Create a PLAN.md (optional but recommended)

In your repo root, create `PLAN.md`:

```markdown
# Project Plan

## Current Focus
What the agent should prioritize right now.

## Context
Background information, architecture decisions, constraints.

## Notes
Session summaries, progress updates, decisions made.
```

- **Current Focus**: You control this - tells the agent what to work on
- **Context**: Background the agent needs
- **Notes**: Collaborative space - agent asks before updating

## For Humans: Daily Workflow

### Check agent progress
```bash
taskagent project:<name> list
taskagent <id> info          # See details + annotations
```

### Review what agents discovered
```bash
taskagent +side_quest list   # Exploratory work
taskagent discovered_from.any: list  # Work found during other tasks
```

### Create tasks for agents
```bash
taskagent add "Implement feature X" project:<name> details:"Context about why and how"
```

### Review completed work
When an agent marks something done, check:
- The git changes
- The task annotations (session notes)
- The PLAN.md notes section

## For Humans: Understanding Agent Annotations

Agents write annotations in this format:
```
COMPLETED: What was finished
IN PROGRESS: Current state
BLOCKERS: What's stuck
KEY DECISIONS: Important choices made
NEXT: Immediate next step
LEARNING: New information acquired (user preference, codebase pattern)
MISALIGNMENT: Agent went wrong direction, was corrected
```

These survive context compaction, so you can understand what happened even if the conversation is lost.

### Learnings vs Misalignments

- **LEARNING** = New information acquired (could be proactive discovery)
  - "User prefers fd over find"
  - "Deploy pipeline is in .github/workflows/"
  
- **MISALIGNMENT** = Agent made wrong assumption, was corrected (implies wasted effort)
  - "Assumed React class components, codebase uses functional only"
  - "Put config in src/, should have been lib/"

A misalignment often produces a learning - both should be recorded.

## Task Lifecycle

```
┌─────────────┐
│   Created   │  Human or agent creates task
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   pending   │  Waiting to be picked up
└──────┬──────┘
       │  taskagent <id> start
       ▼
┌─────────────┐
│ in_progress │  Agent working on it
└──────┬──────┘
       │  Checkpoints: annotations added
       │
       ├──► taskagent <id> stop  ──► back to pending
       │
       │  @task-reviewer reviews
       ▼
┌─────────────┐
│    done     │  taskagent <id> done
└─────────────┘
```

## The Task Reviewer

Before marking a task done, agents should invoke `@task-reviewer`:

```
@task-reviewer Review task 42 - I think I'm done
```

The reviewer:
- Checks the original goal in `details`
- Reviews git changes
- Reports only criticism (no praise)
- Helps catch "I think I'm done but forgot something"

## The Taskagent Reader

A read-only subagent for querying the taskagent database. Use for:
- Retrieving learnings/misalignments from recent tasks
- Summarizing project status across multiple tasks
- Querying task state without risk of modification

```
@taskagent-reader What's the status of project myproject?
@taskagent-reader Retrieve learnings and misalignments from tasks modified today
```

The reader is automatically invoked during `/handoff` to extract session data from taskagent.

## The Code Reviewer

A pre-submission reviewer for PRs/branches against external tickets (Jira, GitHub Issues). Unlike task-reviewer (which verifies taskagent task completion), code-reviewer checks:
- Jira ticket alignment - does the code satisfy ticket requirements?
- Security vulnerabilities, error handling gaps
- Test coverage, maintainability concerns

Invoke before creating PRs or finishing Jira tickets:

```
@code-reviewer Review for PROJ-123
@code-reviewer Review PR #42
```

The code-reviewer automatically:
- Extracts ticket ID from branch name if not provided
- Invokes @taskagent-reader for related task context
- Diffs against origin/HEAD

## Code Reviewer vs Task Reviewer

| Aspect | code-reviewer | task-reviewer |
|--------|---------------|---------------|
| **Trigger** | Before PR/merge | Before `taskagent done` |
| **Scope** | Jira ticket + git changes | Taskagent task completion |
| **Focus** | "Does code meet ticket requirements?" | "Was the work actually done?" |
| **Use** | Pre-submission (external tickets) | Pre-completion (internal tasks) |

**When to use which:**
- Jira ticket work → code-reviewer then task-reviewer
- Internal taskagent-only work → task-reviewer only
- Quick PR review request → code-reviewer

## Session Handoff

Use `/handoff` to perform a structured session handoff. This:

1. **Summarizes learnings and misalignments** from the conversation
2. **If taskagent was used**: Invokes `@taskagent-reader` to retrieve task state and recorded annotations
3. **Checkpoints active tasks** in taskagent (next steps stay there)
4. **Writes to plan file**:
   - `## Learnings` section (new learnings/misalignments with dates)
   - `## Notes` section (high-level direction/goal alignment)

The plan file contains strategic information (where are we going, what did we learn). Taskagent contains tactical information (next concrete steps).

### Plan File Structure After Handoff

```markdown
# Project Plan

## Current Focus
What the agent should prioritize right now.

## Context
Background information, architecture decisions, constraints.

## Learnings
- 2025-11-27: LEARNING: User prefers fd over find
- 2025-11-27: MISALIGNMENT: Assumed REST, project uses GraphQL

## Notes
Session summaries, progress updates, decisions made.
```

## Taskagent vs Regular task

You have two separate taskwarrior instances:
- `task` - Your personal task management
- `taskagent` - Agent-specific work tracking

They use different configs and data directories, so they don't interfere.

## Key Files

| File | Purpose |
|------|---------|
| `~/.config/task/taskagentrc` | Taskagent configuration |
| `~/.local/state/taskagent/` | Taskagent data |
| `~/.config/agents/skills/taskagent/SKILL.md` | Agent instructions |
| `~/.config/opencode/agent/task-reviewer.md` | Reviewer subagent |
| `~/.config/opencode/agent/taskagent-reader.md` | Read-only taskagent analyst |
| `~/.config/opencode/agent/code-reviewer.md` | Pre-submission PR/branch reviewer |
| `~/.config/opencode/command/handoff.md` | Session handoff command |
| `~/org/projects/<project>.md` | Project context (vimwiki) |
| `<repo>/PLAN.md` | Per-project agent plan |

## Custom Fields (UDAs)

| Field | Purpose |
|-------|---------|
| `details` | Initial context, the "why" behind a task |
| `discovered_from` | Links to parent task when work is discovered |

## Quick Reference

```bash
# See what's ready for agents
taskagent ready

# See in-progress work
taskagent +in_progress list

# See all tasks for a project
taskagent project:<name> list

# Full task details with annotations
taskagent <id> info

# Create a task
taskagent add "Title" project:<name> details:"Context"

# See discovered/side work
taskagent +side_quest list
```

## Multi-Machine Sync

Taskagent data is stored locally in `~/.local/state/taskagent`. If you need to sync across multiple machines, use taskwarrior's built-in sync capability with a taskd server or compatible sync service.
