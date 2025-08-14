"""
For getting data out of ipython.
"""

import importlib

if importlib.util.find_spec("clipman") is None:
    import sys

    sys.exit(0)

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

    clipman.set(getrepr(data))
