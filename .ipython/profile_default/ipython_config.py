import imp

c = get_config()  # noqa
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalIPythonApp.display_banner = False
c.InteractiveShell.colors = "linux"
c.TerminalInteractiveShell.highlighting_style = "dracula"  # "solarized-dark"
c.TerminalInteractiveShell.autoformatter = "black"

try:
    imp.find_module("pyflyby")
    c.InteractiveShellApp.extensions.append("pyflyby")
except ImportError:
    pass

# c.TerminalInteractiveShell.shortcuts = [
#     {
#         "command": "IPython:auto_suggest.accept",
#         "new_keys": ["c-z"],
#     }
# ]
## Shortcut style to use at the prompt. 'vi' or 'emacs'.
#  Default: 'emacs'
c.TerminalInteractiveShell.editing_mode = "vi"

## Set the editor used by IPython (default to $EDITOR/vi/notepad).
#  Default: 'vim'
# c.TerminalInteractiveShell.editor = 'vim'
