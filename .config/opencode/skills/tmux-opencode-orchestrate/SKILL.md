---
name: tmux-opencode-orchestrate
description: Coordinate OpenCode v2 sessions displayed in Neovim Floaterms inside tmux. Use for worker status, explicit-session prompt dispatch, interrupting work, or reconnecting a worker client.
---

# OpenCode v2 workers

Clients share one authenticated background service. A pane, editor, and session
are separate identities. Never infer the selected session from the daemon PID,
its environment, or the most recently updated session. Obtain exact session IDs
from the user and confirm each session's directory before dispatch.

## Inspect

Use the `opencode` executable associated with the workers. Its `api` command
handles service discovery and authentication; do not print service credentials.
For isolated testing, use the staged wrapper and its staged state directory.

```sh
opencode service status
opencode api get /api/session
opencode api get /api/session/active
opencode api get "/api/session/$SID"
opencode api get "/api/session/$SID/context"
opencode api get "/api/session/$SID/form"
opencode api get "/api/session/$SID/permission"
```

Session lists are paginated. Inspect children as well as the root. A target is
ready only when its session tree is inactive and has no pending permission or
form requests. Inactivity alone does not prove the requested work is finished;
inspect its outcome and transcript. Capture pane text only for visual debugging.

## Dispatch and interrupt

Do not type into the TUI or a permission dialog. Submit structured input to an
explicit session after checking readiness. Preserve its selected agent/model.

```sh
opencode api post "/api/session/$SID/prompt" \
  --data "$(jq -n --arg text "$PROMPT" '{text:$text,delivery:"queue"}')"
opencode api post "/api/session/$SID/interrupt?resume=false"
```

Prompt admission is asynchronous; keep the returned inbox ID and verify the
matching input/result. Do not blindly retry uncertain delivery. Re-check state
before each dispatch; multiple targets are not an atomic broadcast.

## Reconnect a client

After confirming the target session is idle, a known Neovim socket can recreate
its named Floaterm with `OpencodeFloat --session ses_XXX`. The production launcher
must use `opencode` without the v1 `--port 0` flag. Re-query the Floaterm job ID
after reconnecting. Restarting the shared service affects all workers: never use
`service restart` as a single-worker restart.

Neither `$NVIM` nor the service process environment identifies every attached
editor. Require an explicit editor association or user-provided socket.
