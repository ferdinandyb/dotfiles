# Tmux

When trying to interact with tmux use the tmux-mcp-handler subagent whenever possible.

If you are not sending commands to a shell (e.g. zsh), but something else (like
ipython), then you need to use raw mode and CANNOT use TMUX_MCP_START/DONE idiom.

When I ask you to become an orchestrator, that means you need to spawn
additional claude code instances in new window but the same session and have
them do subtasks.
