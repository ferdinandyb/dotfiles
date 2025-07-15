""" """

import importlib

if importlib.util.find_spec("pyspark") is None:
    import sys

    sys.exit(0)

from pyspark.sql import DataFrame
from pyspark.sql import functions as F  # noqa: F401


def dataframe_checkpoint_table(self, path: str, overwrite=False):
    if overwrite or not self.sparkSession.catalog.tableExists(path):
        self.write.mode("overwrite").saveAsTable(path)
    return self.sparkSession.read.table(path)


setattr(DataFrame, "checkpoint", dataframe_checkpoint_table)


def dataframe_display(self):
    """
    This exists when working in a databricks notebook
    """
    return self.toPandas()


if not hasattr(DataFrame, "display"):
    setattr(DataFrame, "display", dataframe_display)
