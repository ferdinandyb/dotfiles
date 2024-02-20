# Retire the middle-man

Tmux is awesome, and I use it everyday, but there's one big issue with it: when
using tmux, anything emitted in the terminal is first parsed by tmux and then it
by then by the terminal emulator. This not only slows down rendering, it also
introduces a lot of opportunities for bugs, misaligned terminal capabilities
etc.

This is an attempt at a brief overview of what user-facing capabilites _I_ would
need to forgo the use of tmux. I don't consider myself a tmux power user, so
there might be other thing other people would miss.

## What tmux does for me

These are the tmux features I use:

- splits (panes): tmux can split the screen in a tiling windows manager style
- tabs (windows): tmux can create multiple numbered tabs that can house splits
  (panes)
- sessions: tabs are grouped into named sessions, you can switch between
  sessions, detach from sessions (which keeps running all the processes in your
  splits while detached) or attach multiple instances of tmux to same session
- remembering sessions: with a plugin, it is possible to save some state of the
  sessions even if the tmux daemon is restarted, these are: split/pane layouts
  and what program was running in it (e.g. restart vim from a Session.vim object
  etc)
- statusline: to always know where you are
- copy-paste: keybindings to copy and paste in a vim-like fashion from a pane
  (the host terminal emulator has no idea that lines should wrap in the middle
  if you have a split)

Although I use this locally as well, it's importance is when doing remote work.
I ssh over to the machine. I open a single instance of tmux. It has multiple
sessions each corresponding to a specific project I'm working on, so I can
quickly select the current project I want to work on. This has me in the correct
workdir, for example vim opened on a left pane, and an ipython REPL opened on
the other pane. The REPL has been running for maybe days. If I open a new
tab/split I'm still on the remote machine, in the same directory. If my ssh
connection drops for some reason I can just go back in. If I need to let
something run overnight, I can just leave it there.

Obviously, locally this is less useful, since one could theoretically do
something similar with a tiling WM, but having named sessions of a collection of
terminal windows is something I still find useful, and more importantly, I don't
have to have a different set of keybinds and working paradigm because I happen
to be on a local machine.

## What I would need to drop this

Essentially something like [monomux](https://github.com/whisperity/monomux)
working closely together with a terminal emulator to achieve the above. Unlike
tmux, a monomux session only has a single pty. As far as I understand tmux needs
to reparse everything to be able to show tabs, panes, statusbar even if not
using splits, and definitely needs to reparse everything to show splits, while
monomux just passes everything through.

- any time I make a split or new tab in the terminal emulator a monomux session
  should be spun up for that specific split
- if the current pane I'm splitting is an ssh session, the new split should
  first ssh over to the same directory and _then_ spawn a new monomux session on
  the remote machine
- a layout of splits and tabs should be able to get a name/number and since
  everything is connected to a monomux, you should be able to switch between
  named sessions in the same OS window: the terminal emulator needs to keep
  which monomux session corresponds to what pane, and what the tab/split layout
  was
- the terminal emulator should have a statusline which can show session/pane/tab
  information
