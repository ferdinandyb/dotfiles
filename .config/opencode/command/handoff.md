---
description: Structured session handoff with learnings capture
---

# Session Handoff

Perform a structured handoff for the current session. This captures learnings, misalignments, and session state for future sessions.

## Steps

### 1. Identify the Plan File

Determine the plan file for this session:
- Check if an org/projects file was referenced - look for `plan file:` field
- If working in a repo, check for PLAN.md or similar in the repo root
- If no plan file exists, ask the user where to write the handoff

### 2. Summarize Learnings and Misalignments

From the conversation history, identify and summarize:

**Learnings** - New information acquired during the session:
- User preferences discovered
- Codebase patterns learned
- Correct approaches identified

**Misalignments** - Corrections that occurred:
- Wrong assumptions made
- Direction changes after user feedback
- Mistakes that needed fixing

### 3. If Taskagent Was Used

If taskagent was used during this session:

a) Invoke `@taskagent-reader` to retrieve task state and any recorded learnings/misalignments:
```
@taskagent-reader Retrieve session summary for handoff.
- Project: <project name if known>
- Focus on: tasks modified this session, any LEARNING/MISALIGNMENT annotations
- Return: task progress summary, recorded learnings, recorded misalignments
```

b) Checkpoint any active tasks:
```bash
taskagent <id> annotate "HANDOFF: <current state>. NEXT: <next step>."
```

### 4. Write to Plan File

Update the plan file with:

**## Learnings section** (create if doesn't exist):
- Add new learnings with date prefix
- Add misalignments with date prefix
- Format:
  ```markdown
  ## Learnings

  - YYYY-MM-DD: LEARNING: <description>
  - YYYY-MM-DD: MISALIGNMENT: <description>
  ```

**## Notes section** (or equivalent):
- Brief session summary (1-2 sentences on what was accomplished)
- High-level direction/goal alignment (are we on track?)

Do NOT put tactical next steps in the plan file - those belong in taskagent annotations.

### 5. Confirm Handoff

Report to the user:
- What was written to the plan file
- If taskagent: current task state
- Any outstanding items for next session
