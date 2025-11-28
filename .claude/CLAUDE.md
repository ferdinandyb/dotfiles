@~/.config/agents/git.md
@~/.config/agents/tmux.md
@~/.config/agents/directives.md


# shell tools

I prefer ugrep (ug) over grep, and fd-find (fd) over find.

# personal config

I use `yadm` for my dotfiles. There is a README for it at ~/README.md
`yadm` is a drop in replacement for `git` that uses my dotfiles repo.

# nvim mcp

Check the cursor position and visual select in nvim for possibly important context.

# opencode

If you are running in opencode, remember that after every edit formatters are invoked. For example, when editing python files you need to add import and usage together, otherwise the unused import rule will be triggered and the imports removed.

# data

Avoid reading large data files directly, to preserve context. Delegate it to a subagent or use tools like ugrep, ripgrep or jq.
