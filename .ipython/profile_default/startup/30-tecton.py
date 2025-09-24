import importlib
import sys
from packaging import version

if importlib.util.find_spec("tecton") is None:
    sys.exit(0)

import tecton
from tecton._internals import spark_utils
from tecton_core import conf


EXECUTOR_ENV_VARIABLES = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "HIVE_METASTORE_HOST",
    "HIVE_METASTORE_PORT",
    "HIVE_METASTORE_USERNAME",
    "HIVE_METASTORE_DATABASE",
    "HIVE_METASTORE_PASSWORD",
]

tecton_version = version.parse(tecton.__version__)
if tecton_version >= version.parse("1.0.0"):
    sys.exit(0)


def _patched_get_basic_spark_session_builder():
    from pyspark.sql.connect.session import SparkSession as DefaultSparkSession

    builder = DefaultSparkSession.builder

    if conf.get_or_none("AWS_ACCESS_KEY_ID") is not None:
        builder = builder.config(
            "spark.hadoop.fs.s3a.access.key", conf.get_or_none("AWS_ACCESS_KEY_ID")
        )
        builder = builder.config(
            "spark.hadoop.fs.s3a.secret.key", conf.get_or_none("AWS_SECRET_ACCESS_KEY")
        )
    if conf.get_or_none("HIVE_METASTORE_HOST") is not None:
        builder = (
            builder.enableHiveSupport()
            .config(
                "spark.hadoop.javax.jdo.option.ConnectionURL",
                f"jdbc:mysql://{conf.get_or_none('HIVE_METASTORE_HOST')}:{conf.get_or_none('HIVE_METASTORE_PORT')}/{conf.get_or_none('HIVE_METASTORE_DATABASE')}",
            )
            .config(
                "spark.hadoop.javax.jdo.option.ConnectionDriverName",
                "com.mysql.cj.jdbc.Driver",
            )
            .config(
                "spark.hadoop.javax.jdo.option.ConnectionUserName",
                conf.get_or_none("HIVE_METASTORE_USERNAME"),
            )
            .config(
                "spark.hadoop.javax.jdo.option.ConnectionPassword",
                conf.get_or_none("HIVE_METASTORE_PASSWORD"),
            )
        )
    for v in EXECUTOR_ENV_VARIABLES:
        if conf.get_or_none(v) is not None:
            builder = builder.config(f"spark.executorEnv.{v}", conf.get_or_none(v))
    return builder


spark_utils._get_basic_spark_session_builder = _patched_get_basic_spark_session_builder
