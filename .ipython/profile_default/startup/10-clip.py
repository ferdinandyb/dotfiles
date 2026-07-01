"""
For getting data out of ipython.
"""

import base64
import importlib
import sys


def _tty_write(text):
    with open("/dev/tty", "w") as tty:
        tty.write(text)


def _osc52_copy(text):
    """Write text to the system clipboard via OSC 52 (see bin/clip)."""
    b64 = base64.b64encode(text.encode()).decode()
    _tty_write(f"\033]52;c;{b64}\a")


try:
    _tty_write("")
    _use_osc52 = True
except OSError:
    _use_osc52 = False

if not _use_osc52 and importlib.util.find_spec("clipman") is None:
    sys.exit(0)

if not _use_osc52:
    import clipman

    clipman.init()


def clip(data=None, **kwargs):
    """

    If no data is given, it will try to copy the last output stored in
    Out. If an input is given, it will try to do something smart.

    - pandas: to_markdown() called

    """

    def getrepr(data):
        """

        We can't use match/case here to make sure it doesn't die in an
        older environment.  We also need to try/except any reference to
        certain types coming from modules which may or may not be present.

        """
        if hasattr(data, "to_markdown"):
            data = data.to_markdown(**kwargs)
        elif hasattr(data, "toPandas"):
            data = data.toPandas().to_markdown(**kwargs)

        if data is not None:
            # using __repr__ here would yank verbatim as you
            # would type in source code (e.g. leave a \n in )
            return data.__str__()
        return Out[max(list(Out.keys()))]

    text = getrepr(data)
    if _use_osc52:
        _osc52_copy(text)
    else:
        clipman.set(text)
