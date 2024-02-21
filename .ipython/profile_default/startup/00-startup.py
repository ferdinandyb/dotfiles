try:
    import numpy as np
except ImportError:
    pass
try:
    import pandas as pd

    pd.options.display.max_columns = 0
except ImportError:
    pass
try:
    from matplotlib import pyplot as plt
except ImportError:
    pass


try:
    import clipman

    clipman.init()

    def clip(data=None):
        """

        If no data is given, it will try to copy the last output stored in
        Out. If an input is given, it will try to do something smart.

        - pandas: to_markdown() called

        """

        def getrepr(data):
            try:
                if isinstance(data, pd.DataFrame):
                    data = data.to_markdown()
            except NameError:
                pass
            if data is not None:
                # using __repr__ here would yank verbatim as you
                # would type in source code (e.g. leave a \n in )
                return data.__str__()
            return Out[max(list(Out.keys()))]

        clipman.set(getrepr(data))

except ImportError:
    pass
