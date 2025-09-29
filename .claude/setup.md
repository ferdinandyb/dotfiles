# Setting up claude

Claude's configuration is atrocious, so some things just need to be written up,
because I can't version control them properly via the settings file.

```
claude mcp add-json --scope user "tmux" '{"command":"npx","args":["-y","tmux-mcp"]}'
claude mcp add --scope user --transport sse atlassian https://mcp.atlassian.com/v1/sse
```
