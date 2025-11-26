# Agentic Workflow Guide

This document explains how to use the taskagent-based workflow for AI coding agents.

## Overview

The system consists of:
- **taskagent** - A taskwarrior instance dedicated to agent work tracking
- **taskagent skill** - Instructions for agents on how to use taskagent
- **task-reviewer subagent** - A grumpy reviewer that checks work before completion
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
```

These survive context compaction, so you can understand what happened even if the conversation is lost.

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
