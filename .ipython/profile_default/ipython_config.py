import importlib

from pygments.styles import get_all_styles

c = get_config()  # noqa
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalIPythonApp.display_banner = False
c.InteractiveShell.colors = "linux"
if "dracula" in list(get_all_styles()):
    c.TerminalInteractiveShell.highlighting_style = "dracula"  # "solarized-dark"
c.TerminalInteractiveShell.autoformatter = "black"
# c.InteractiveShell.pdb = 1

if importlib.util.find_spec("pyflyby") is not None:
    c.InteractiveShellApp.extensions.append("pyflyby")

if importlib.util.find_spec("ipython_ctrlr_fzf") is None:
    try:
        import subprocess

        subprocess.run(
            ["pip", "install", "ipython-ctrlr-fzf"],
            capture_output=True,
            check=False,
            timeout=30,
        )
        importlib.invalidate_caches()
    except Exception:
        pass

if importlib.util.find_spec("ipython_ctrlr_fzf") is not None:
    c.InteractiveShellApp.extensions.append("ipython_ctrlr_fzf")


c.TerminalInteractiveShell.shortcuts = [
    {
        "command": "IPython:auto_suggest.accept",
        "match_keys": ["c-z"],
    }
]

from IPython.terminal.prompts import Prompts
from prompt_toolkit.enums import EditingMode
from prompt_toolkit.formatted_text import fragment_list_width
from pygments.token import Token


class Prompt(Prompts):
    """
    This is a copy of the original prompt, which I plan to upgrade slightly.
    """

    def vi_mode(self):
        if (
            getattr(self.shell.pt_app, "editing_mode", None) == EditingMode.VI
            and self.shell.prompt_includes_vi_mode
        ):
            mode = str(self.shell.pt_app.app.vi_state.input_mode)
            if mode.startswith("InputMode."):
                # mode is one of INSERT, NAVIGATION, INSERT_MULTIPLE, REPLACE, REPLACE_SINGLE
                mode = mode[10:13].lower()
            elif mode.startswith("vi-"):
                mode = mode[3:6]
            return "[" + mode + "] "
        return ""

    def in_prompt_tokens(self):
        return [
            (Token.Prompt, self.vi_mode()),
            (Token.Prompt, "In ["),
            (Token.PromptNum, str(self.shell.execution_count)),
            (Token.Prompt, "]: "),
        ]

    def _width(self):
        return fragment_list_width(self.in_prompt_tokens())

    def continuation_prompt_tokens(self, width=None):
        if width is None:
            width = self._width()
        return [
            (Token.Prompt, (" " * (width - 5)) + "...: "),
        ]

    def rewrite_prompt_tokens(self):
        width = self._width()
        return [
            (Token.Prompt, ("-" * (width - 2)) + "> "),
        ]

    def out_prompt_tokens(self):
        return [
            (Token.OutPrompt, "Out["),
            (Token.OutPromptNum, str(self.shell.execution_count)),
            (Token.OutPrompt, "]: "),
        ]


c.TerminalInteractiveShell.prompts_class = Prompt
## Shortcut style to use at the prompt. 'vi' or 'emacs'.
#  Default: 'emacs'
c.TerminalInteractiveShell.editing_mode = "vi"

## Set the editor used by IPython (default to $EDITOR/vi/notepad).
#  Default: 'vim'
# c.TerminalInteractiveShell.editor = 'vim'
